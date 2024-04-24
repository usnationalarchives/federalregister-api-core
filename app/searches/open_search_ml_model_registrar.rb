# This class creates a model group, downloads the ML model, and deploys the ML model to OpenSearch.
class OpenSearchMlModelRegistrar
  extend Memoist

  @model_id = nil
  def self.model_id
    # OpenSearch needs a way to reference the active model id, but we don't want to be continually looking this up
    # Potential performance optimization: Investigate whether there's a better way of handling this
    @model_id || update_model_id
  end

  def self.update_model_id
    @model_id = new.models.first&._id
  end

  def self.destroy_all_models!
    model_ids = OpenSearchMlModelRegistrar.new.models.map{|x| x._id}
    # Undeploy models
    model_ids.each{|id| puts id; response = Faraday.post("http://elasticsearch.brandon-fr.svc.cluster.local:9200/_plugins/_ml/models/#{id}/_undeploy"); puts response.body}

    # Deploy models
    model_ids.each{|id| puts id; response = Faraday.delete("http://elasticsearch.brandon-fr.svc.cluster.local:9200/_plugins/_ml/models/#{id}"); puts response.body}
  end

  def self.perform
    new.perform
  end

  def perform
    # Register a model group (an ML model needs to exist within a model group)
    if model_groups.count == 0
      model_group_id = register_model_group! 
      puts "Registered a new model group: #{model_group_id}"
    elsif model_groups.count == 1
      model_group_id = model_groups.first._id
      puts "A model group already exists: #{model_group_id}"
    else
      raise model_groups.inspect
    end

    # Register the model
    if models.count == 0
      model_id = register_model!(model_group_id)
      puts "Registered model id #{model_id}"
    elsif models.count == 1
      model_id = models.first._id
      puts "A model already exists: #{model_id}"
    else
      raise models.inspect
    end

    # Deploy the model
    deploy_model!(model_id)
  end

  def models
    response = http_post(
      "/_plugins/_ml/models/_search",
      {
        query: {
          match_all: {}
        },
        size: 1000,
      }
    )
    parsed_response = JSON.parse(response.body).dig("hits","hits")
    
    parsed_response.
      map{|x| OpenStruct.new(x) }.
      select{|x| x.dig("_source","model_group_id")} #Note, depending on a model's size, it will be split into 'chunks' on deployment.  We're attempting to filter to the main model of concern here by looking for the model that has a model group id assigned
  end
  memoize :models


  private

  def http_post(endpoint, body=nil)
    response = Faraday.post("#{base_url}#{endpoint}") do |req|
      req.headers['Content-Type'] = 'application/json'

      if body
        req.body = body.to_json
      end
    end
  end

  def deploy_model!(model_id)
    existing_model = models.first
    if existing_model && existing_model.dig("_source","model_state") == "DEPLOYED"
      puts "A model has already been deployed: #{model_id}"
    else
      response = http_post("/_plugins/_ml/models/#{model_id}/_deploy")

      if !response.success?
        raise response.body
      else
        task_id = JSON.parse(response.body).fetch("task_id")
        model_id = poll_until_complete(task_id, "model_id")
        puts "#{model_id} deployed"
      end
    end
  end

  def register_model!(model_group_id)
    response = http_post(
      "/_plugins/_ml/models/_register",
      {
        "name": "huggingface/sentence-transformers/msmarco-distilbert-base-tas-b",
        "version": "1.0.2",
        "model_group_id": model_group_id,
        "model_format": "TORCH_SCRIPT"
      }
    )

    if response.success?
      task_id = JSON.parse(response.body).fetch("task_id")
      model_id = poll_until_complete(task_id, "model_id")
    else
      raise response.body
    end
  end

  def poll_until_complete(task_id, desired_response_key)
    response = check_task(task_id)
    while response.nil?
      sleep 5
      response = check_task(task_id)
    end
    response.fetch(desired_response_key)
  end

  def check_task(task_id)
    endpoint = "/_plugins/_ml/tasks/#{task_id}"
    response = Faraday.get("#{base_url}#{endpoint}")
    parsed_response = JSON.parse(response.body)
    if parsed_response.fetch("state") == "COMPLETED"
      puts parsed_response
      parsed_response
    else
      puts "Task ID #{task_id} not yet complete:"
      puts parsed_response
      nil #no-op
    end
  end

  def register_model_group!
    response = http_post(
      "/_plugins/_ml/model_groups/_register",
      {
        "name":        "local_model_group_throwaway",
        "description": "A model group for local models"
      }
    )

    if response.success?
      task_id = JSON.parse(response.body).fetch("model_group_id").fetch("task_id")
    else
      raise response.body
    end
  end

  def model_groups
    response = http_post(
      "/_plugins/_ml/model_groups/_search",
      {
        query: {
          match_all: {}
        },
        size: 1000,
      }
    )

    parsed_response = JSON.parse(response.body).dig("hits","hits")
    model_groups = parsed_response.map{|x| OpenStruct.new(x) }
  end
  memoize :model_groups

  def base_url
    Settings.elasticsearch.host
  end

end

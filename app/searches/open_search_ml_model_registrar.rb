# This class is responsible for creating a model group, ML model, and deploying the ML model.

class OpenSearchMlModelRegistrar
  extend Memoist

  def self.destroy_all_models!
    model_ids = OpenSearchMlModelRegistrar.new.models.map{|x| x._id}
    # Undeploy models
    model_ids.each{|id| puts id; response = Faraday.post("http://elasticsearch.brandon-fr.svc.cluster.local:9200/_plugins/_ml/models/#{id}/_undeploy"); puts response.body}

    # Deploy models
    model_ids.each{|id| puts id; response = Faraday.delete("http://elasticsearch.brandon-fr.svc.cluster.local:9200/_plugins/_ml/models/#{id}"); puts response.body}
  end

  def perform
    # Register a model group (this is needed in order to register an ML model)
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
      puts "A model already exists: id #{model_id}"
    else
      raise models.inspect
    end

    # Deploy the model
    deploy_model!(model_id)
  end

  # private

  def deploy_model!(model_id)
    endpoint = "/_plugins/_ml/models/#{model_id}/_deploy"

    if models.first.dig("_source","model_state") == "DEPLOYED"
      puts "#{model_id} has already been deployed"
    else
      response = Faraday.post("#{base_url}#{endpoint}") do |req|
        req.headers['Content-Type'] = 'application/json'
      end

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
    endpoint = "/_plugins/_ml/models/_register"

    response = Faraday.post("#{base_url}#{endpoint}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        "name": "huggingface/sentence-transformers/msmarco-distilbert-base-tas-b",
        "version": "1.0.2",
        "model_group_id": model_group_id,
        "model_format": "TORCH_SCRIPT"
      }.to_json
    end

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
    endpoint = "/_plugins/_ml/model_groups/_register"

    response = Faraday.post("#{base_url}#{endpoint}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        "name":        "local_model_group_throwaway",
        "description": "A model group for local models"
      }.to_json
    end

    if response.success?
      task_id = JSON.parse(response.body).fetch("model_group_id").fetch("task_id")
    else
      raise response.body
    end
  end

  def model_groups
    endpoint = "/_plugins/_ml/model_groups/_search"

    # Define the request body
    request_body = {
      query: {
        match_all: {}
      },
      size: 1000,
      # _source: ["id"] 
    }

    # Send the request
    response = Faraday.post("#{base_url}#{endpoint}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = request_body.to_json
    end
    parsed_response = JSON.parse(response.body).dig("hits","hits")
    model_groups = parsed_response.map{|x| OpenStruct.new(x) }
  end
  memoize :model_groups

  def models
    endpoint = "/_plugins/_ml/models/_search"

    # Define the request body
    request_body = {
      query: {
        match_all: {}
      },
      size: 1000,
      # _source: ["id"] 
    }

    # Send the request
    response = Faraday.post("#{base_url}#{endpoint}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = request_body.to_json
    end
    parsed_response = JSON.parse(response.body).dig("hits","hits")
    
    parsed_response.
      map{|x| OpenStruct.new(x) }.
      select{|x| x.dig("_source","model_group_id")} #Note, depending on a model's size, it will be split into 'chunks' on deployment.  We're attempting to filter to the main model here by looking for the model that has a model group id assigned
  end
  memoize :models

  def base_url
    "http://elasticsearch.brandon-fr.svc.cluster.local:9200"
  end

  

end

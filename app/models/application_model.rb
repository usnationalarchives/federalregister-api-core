class ApplicationModel < ActiveRecord::Base

  self.abstract_class = true
  include ViewHelper

  # More performant than simply ORDER BY RAND()
  # See http://www.paperplanes.de/2008/4/24/mysql_nonos_order_by_rand.html for inspiration
  def self.random_selection(n)
    scoped(:joins => "JOIN (SELECT ID FROM #{table_name} ORDER BY RAND() LIMIT #{n.to_i}) AS random_ids ON #{table_name}.id = random_ids.id")
  end

  def self.limit(n)
    scoped(:limit => n)
  end

  # Calculates the results immediately, so additional query filters cannot be appended
  def self.preload(*associations)
    results = scoped({})
    preload_associations(results, associations)
    results
  end

  # Force MySQL to join tables in provided order.
  #   Calculates the results immediately, so additional query filters cannot be appended
  def self.straight_join
    sql = construct_finder_sql(self.current_scoped_methods[:find])
    sql.sub!(/^SELECT/, 'SELECT STRAIGHT_JOIN')
    find_by_sql(sql)
  end

  def self.active_hash?
    false
  end

  def self.delta_index_names
    []
  end

  def self.core_index_names
    raise NotImplementedError
  end

  ES_INDEXING_RETRY_LIMIT = 1
  def self.bulk_index(active_record_collection, refresh: false, repository: default_repository)
    current_time = Time.current
    body = active_record_collection.each_with_object(Array.new) do |instance, request_body|
      request_body << { index: { _index: repository.index_name, _id: instance.id } }
      request_body << instance.to_hash.merge(indexed_at: current_time.utc.iso8601)
    end

    remaining_retries = ES_INDEXING_RETRY_LIMIT
    begin
      response = repository.client.bulk body: body, refresh: refresh
      if response.fetch('errors')
        failed_items  = response.fetch('items').select{|x| x.fetch('index')['error'] }
        failed_ids    = failed_items.map{|x| x.fetch("index").fetch("_id") }
        error_message = "Some entries failed during the bulk index (entry_ids: #{failed_ids}).  Full errors: #{failed_items}"
        if Rails.env.development?
          raise error_message
        else
          Honeybadger.notify(error_message)
        end
      end
    rescue Faraday::TimeoutError => e
      if remaining_retries > 0
        remaining_retries -= 1
        sleep 5 # Account for network blips since ES client auto-retries
        retry
      else
        raise e
      end
    end

    if refresh
      repository.refresh_index!
    end
  end

  def self.bulk_update(active_record_collection, refresh: false, repository: default_repository, attribute:)
    current_time = Time.current
    body = active_record_collection.each_with_object(Array.new) do |instance, request_body|
      request_body << { update: { _index: repository.index_name, _id: instance.id } }
      request_body << {:doc => {attribute.key => attribute.method.call(instance)}}
    end

    remaining_retries = ES_INDEXING_RETRY_LIMIT
    begin
      response = repository.client.bulk body: body, refresh: refresh
      Rails.logger.info(response)

      if response.fetch('errors')
        if Rails.env.development?
          raise response.fetch('errors')
        else
          Honeybadger.notify(response.fetch('errors'))
        end
      end
    rescue Faraday::TimeoutError => e
      if remaining_retries > 0
        remaining_retries -= 1
        sleep 5 # Account for network blips since ES client auto-retries
        retry
      else
        raise e
      end
    end

    if refresh
      repository.refresh_index!
    end
  end

  def reindex!
    self.class.bulk_index([self])
  end

end

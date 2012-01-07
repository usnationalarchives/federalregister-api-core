class ApiController < ApplicationController
  private
  def render_json_or_jsonp(data, options = {})
    callback = params[:callback].to_s
    if callback =~ /^\w+$/
      render({:text => "#{callback}(" + data.to_json + ")"}.merge(options))
    else
      render({:json => data.to_json}.merge(options))
    end
  end

  def render_search(search)
    if ! search.valid?
      cache_for 1.day
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
      return
    end

    data = { :count => search.count }
    
    if search.count > 0 && search.results.count > 0
      data[:total_pages] = search.results.total_pages
      
      if search.results.next_page
        data[:next_page_url] = url_for(params.merge(:page => search.results.next_page))
      end
      
      if search.results.previous_page
        data[:previous_page_url] = url_for(params.merge(:page => search.results.previous_page))
      end
      
      data[:results] = search.results.map do |result|
        yield(result)
      end
    end

    render_json_or_jsonp(data)
  end

  def render_one_or_more(model, document_numbers)
    if document_numbers =~ /,/
      document_numbers = params[:id].split(',')
      records = model.all(:conditions => {:document_number => document_numbers})
      
      data = {
        :count => records.count,
        :results => records.map{|record| yield(record)}
      }

      missing = document_numbers - records.map(&:document_number)
      if missing.present?
        data[:errors] = {:not_found => missing}
      end
    else
      record = model.find_by_document_number!(document_numbers)
      data = yield(record)
    end
    render_json_or_jsonp data
  end 

  rescue_from Exception, :with => :server_error if RAILS_ENV != 'development'
  def server_error(exception)
    notify_airbrake(exception)
    render :json => {:status => 500, :message => "Internal Server Error"}, :status => 500
  end
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found if RAILS_ENV != 'development'
  def record_not_found
    render :json => {:status => 404, :message => "Record Not Found"}, :status => 404
  end
  
  rescue_from ActionController::MethodNotAllowed, :with => :method_not_allowed if RAILS_ENV != 'development'
  def method_not_allowed
    render :json => {:status => 405, :message => "Method Not Allowed"}, :status => 405
  end
end

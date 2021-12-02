# allow api endpoints to serve csv if they support it
require 'csv'
class ApiController < ApplicationController
  class RequestError < StandardError; end
  class UnknownFieldError < RequestError; end

  before_action :set_cors_headers
  before_action :enforce_maximum_per_page
  skip_before_action :verify_authenticity_token

  private

  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
  end

  def enforce_maximum_per_page
    params.delete(:maximum_per_page)
  end

  def active_record_based_retrieval?(force=false)
    SETTINGS['elasticsearch']['active_record_based_retrieval'] || force
  end

  def render_json_or_jsonp(data, options = {})
    callback = params[:callback].to_s
    if callback =~ /^[a-zA-Z0-9_\.]+$/
      render({plain: "#{callback}(" + data.to_json + ")", content_type: "application/javascript"}.merge(options))
    else
      render({:json => data.to_json}.merge(options))
    end
  end

  def render_search(search, options={}, metadata_only="0")
    if ! search.valid?
      cache_for 1.day
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
      return
    end

    data = { :count => search.count, :description => search.summary }

    unless metadata_only == "1"
      # NOTE: /documents needs the select clause to be nested inside a SQL block
      select = options.delete(:select)
      options.merge!(sql: {select: select})

      results = search.results(options)

      if search.count > 0 && results.count > 0
        data[:total_pages] = results.total_pages

        if results.next_page
          data[:next_page_url] = index_url(params.merge(:page => results.next_page).permit!)
        end

        if results.previous_page
          data[:previous_page_url] = index_url(params.merge(:page => results.previous_page).permit!)
        end

        data[:results] = results.map do |result|
          yield(result)
        end
      end
    end

    render_json_or_jsonp(data)
  end

  def render_one_or_more(model, document_numbers_or_citations, find_options={}, &block)
    if document_numbers_or_citations =~ /FR/
      data = render_via_citations(model, document_numbers_or_citations, find_options.except(:publication_date), &block)
    else
      data = render_via_document_numbers(model, document_numbers_or_citations, find_options, &block)
    end

    render_json_or_jsonp data
  end

  def render_via_document_numbers(model, document_numbers, find_options={}, &block)
    publication_date = find_options[:publication_date]

    if document_numbers =~ /,/
      document_numbers = document_numbers.split(',')

      records = document_number_based_search_result(
        model,
        find_options,
        document_numbers,
        publication_date
      )

      data = {
        :count   => (active_record_based_retrieval?(model.always_render_document_number_search_results_via_active_record?) ? records.count(:all) : records.count),
        :results => records.map{|record| yield(record)}
      }

      missing = document_numbers - records.map(&:document_number)
      if missing.present?
        data[:errors] = {:not_found => missing}
      end
    else
      if publication_date
        if active_record_based_retrieval?
          record = model.where("document_number = ? AND publication_date = ?", document_numbers, publication_date).first
        else
          record = document_number_based_search_result(model, find_options, document_numbers, publication_date).first
        end

        raise ActiveRecord::RecordNotFound unless record
      else
        if active_record_based_retrieval?
          record = model.find_by_document_number!(document_numbers)
        else
          record = document_number_based_search_result(
            model,
            find_options,
            document_numbers,
            publication_date
          ).first
          raise ActiveRecord::RecordNotFound unless record
        end
      end
      data = yield(record)
    end

    data
  end

  def document_number_based_search_result(model, find_options, document_numbers, publication_date)
    if active_record_based_retrieval?(model.always_render_document_number_search_results_via_active_record?)
      conditions = {document_number: document_numbers}.tap do |hsh|
        if publication_date
          hsh.merge!(publication_date: publication_date)
        end
      end

      combined_options = find_options.except(:publication_date).merge(conditions: conditions)

      [{:agency_name_assignments=>{:agency_name=>:agency}}]
      model.
        includes(combined_options.fetch(:include)).
        select(combined_options.fetch(:select)).
        where(combined_options.fetch(:conditions))
    else
      conditions = {document_numbers: document_numbers}.tap do |hsh|
        if publication_date
          hsh.merge!(publication_date: {is: publication_date})
        end
      end

      model.search_klass.new(conditions: conditions).results
    end
  end

  def render_via_citations(model, citations, find_options={}, &block)
    if citations =~ /,/
      citations = citations.split(',')
    else
      citations = Array(citations)
    end

    records = []
    matched_citations = []
    citations.each do |citation|
      volume, fr_str, page = citation.split(' ')

      if active_record_based_retrieval?
        matches = model.
          includes(find_options.fetch(:include)).
          select(find_options.fetch(:select)).
          where("volume = ? AND start_page <= ? AND end_page >= ?", volume.to_i, page.to_i, page.to_i)
      else
        search = model.search_klass.new(conditions: {volume: volume.to_i})
        search.start_page= ({range_conditions: {lte: page}})
        search.end_page= ({range_conditions: {gte: page}})
        matches = search.results
      end

      if matches.present?
        matched_citations << citation
        records << matches
      end
    end
    records.flatten!

    data = {
      :count => records.count,
      :results => records.map{|record| yield(record)}
    }

    missing = citations - matched_citations
    if missing.present?
      data[:errors] = {:not_found => missing}
    end

    data
  end

  def specified_fields
    if params[:fields]
      params[:fields].reject(&:blank?).map{|f| f.to_s.to_sym}
    end
  end

  def search_filters(search)
    search.filters.map.each_with_object(Hash.new) do |filter, hsh|
      representation = {
        name: filter.name,
        value: filter.value.first.is_a?(Range) ? nil : filter.value.first,
        label: filter.label
      }

      if filter.multi
        hsh[filter.condition] ||= []
        hsh[filter.condition] << representation
      else
        hsh[filter.condition] = representation
      end

      hsh
    end
  end

  rescue_from Exception, :with => :server_error if RAILS_ENV == 'production' || RAILS_ENV == 'staging'
  def server_error(exception)
    Honeybadger.notify(exception)
    render :json => {:status => 500, :message => "Internal Server Error"}, :status => 500
  end

  rescue_from ApiRepresentation::FieldNotFound, :with => :field_not_found
  def field_not_found(exception)
    render :json => {:status => 400, :message => exception.message}, :status => 400
  end

  rescue_from RequestError, :with => :request_error if RAILS_ENV != 'development'
  def request_error(exception)
    render :json => {:status => 400, :message => exception.message}, :status => 400
  end

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  def record_not_found
    render :json => {:status => 404, :message => "Record Not Found"}, :status => 404
  end

  rescue_from ActionController::MethodNotAllowed, :with => :method_not_allowed if RAILS_ENV != 'development'
  def method_not_allowed
    render :json => {:status => 405, :message => "Method Not Allowed"}, :status => 405
  end
end

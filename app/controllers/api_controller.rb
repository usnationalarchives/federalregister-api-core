# allow api endpoints to serve csv if they support it
require 'csv'
class ApiController < ApplicationController
  include Shared::DoesDocumentNumberNormalization
  class RequestError < StandardError; end
  class UnknownFieldError < RequestError; end

  before_action :set_cors_headers
  before_action :enforce_maximum_per_page
  skip_before_action :verify_authenticity_token

  private

  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
  end

  EXECUTIVE_ORDER_CSV_MAXIMUM_PER_PAGE = 10000
  def enforce_maximum_per_page
    if eo_csv_request? && (params[:maximum_per_page].to_i <= EXECUTIVE_ORDER_CSV_MAXIMUM_PER_PAGE)
      # no-op: permit larger EO csv requests
    else
      params.delete(:maximum_per_page)
    end
  end

  def eo_csv_request?
    params[:format] == "csv" &&
      params[:conditions] != "" &&
      params.dig(:conditions, :presidential_document_type) == "executive_order" &&
      params[:controller] == "api/v1/entries"
  end

  def render_json_or_jsonp(data, options = {})
    callback = params[:callback].to_s
    if callback =~ /^[a-zA-Z0-9_\.]+$/
      render({plain: "#{callback}(" + ActiveSupport::JSON.encode(data) + ")", content_type: "application/javascript"}.merge(options))
    else
      render({:json => ActiveSupport::JSON.encode(data)}.merge(options))
    end
  end

  def render_search(search, options={}, metadata_only="0")
    if ! search.valid?
      cache_for 1.day
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
      return
    end

    count = search.count

    data = { :count => count, :description => search.summary }

    unless metadata_only == "1"
      # NOTE: /documents needs the select clause to be nested inside a SQL block
      select = options.delete(:select)
      options.merge!(sql: {select: select})

      results = search.results(options)

      if results.count > 0
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
      document_numbers = document_numbers.
        split(',').
        map{|doc_num| normalized_doc_num(doc_num)}

      records = document_number_based_search_result(
        model,
        find_options,
        document_numbers,
        publication_date
      )

      data = {
        :count   => (model.always_render_document_number_search_results_via_active_record? ? records.count(:all) : records.count),
        :results => records.map{|record| yield(record)}
      }

      missing = document_numbers - records.map(&:document_number)
      if missing.present?
        data[:errors] = {:not_found => missing}
      end
    else
      if publication_date
        record = document_number_based_search_result(model, find_options, document_numbers, publication_date).first

        raise ActiveRecord::RecordNotFound unless record
      else
        record = document_number_based_search_result(
          model,
          find_options,
          document_numbers,
          publication_date
        ).first
        raise ActiveRecord::RecordNotFound unless record
      end
      data = yield(record)
    end

    data
  end

  DOCUMENT_PER_PAGE_LIMIT = 250
  def document_number_based_search_result(model, find_options, document_numbers, publication_date)
    # NOTE: There is not always parity between PI docs and their published equivalents (eg PI doc is 2012-07333 and Entry is 2012-7333).  Thus we need to automatically search for their 0 padded and unpadded equivalents
    document_number_variants = Array.
      wrap(document_numbers).
      map{|doc_num| normalized_doc_num(doc_num)}.
      map {|doc_num| self.class.document_number_variants(doc_num)}.
      flatten

    if model.always_render_document_number_search_results_via_active_record?
      conditions = {document_number: document_number_variants}.tap do |hsh|
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
      conditions = {document_numbers: document_number_variants, per_page: DOCUMENT_PER_PAGE_LIMIT}.tap do |hsh|
        if publication_date
          hsh.merge!(publication_date: {is: publication_date})
        end
      end

      model.search_klass.new(conditions: conditions).results
    end
  end

  def normalized_doc_num(doc_num)
    # replace endash, emdash with hyphen
    hyphen, en_dash, em_dash = "-", "–", "—"
    doc_num.gsub(/[#{en_dash}#{em_dash}]/, hyphen)
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

      search = model.search_klass.new(conditions: {volume: volume.to_i})
      search.start_page= ({range_conditions: {lte: page}})
      search.end_page= ({range_conditions: {gte: page}})
      matches = search.results

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

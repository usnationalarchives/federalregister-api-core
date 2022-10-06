class EsApplicationSearch
  include Rails.application.routes.url_helpers
  extend Memoist
  class InputError < StandardError; end

  attr_accessor :order
  attr_writer :aggregation_field, :date_histogram_interval
  attr_reader :filters, :term, :maximum_per_page, :per_page, :page, :conditions, :valid_conditions, :excerpts

  def per_page=(count)
    per_page = count.to_s.to_i
    if per_page > 1 && per_page <= maximum_per_page
      @per_page = per_page
    else
      @per_page = 20
    end

    @per_page
  end

  def term=(term)
    @term = term.to_s
  end

  def validation_errors
    @errors
  end

  def self.define_filter(filter_name, options = {}, &name_definer)
    attr_reader filter_name
    # refactor to partials...

    define_method "#{filter_name}=" do |val|
      if (val.present? && (val.is_a?(String) || val.is_a?(Integer))) || (val.is_a?(Array) && !val.all?(&:blank?))
        instance_variable_set("@#{filter_name}", val)
        if val.is_a?(Array)
          val.reject!(&:blank?)
        end

        begin
          add_filter options.merge(:value => val, :condition => filter_name, :name_definer => name_definer)
        rescue EsApplicationSearch::InputError => e
          @errors[filter_name] = e.message
        end
      end
    end
  end

  def self.define_date_filter(filter_name, options = {})
    attr_reader filter_name
    condition = filter_name

    define_method "#{filter_name}=" do |hsh|
      if hsh.is_a?(Hash) && hsh.values.any?(&:present?)
        selector = ApplicationSearch::DateSelector.new(hsh)
        instance_variable_set("@#{filter_name}", selector)

        label = options[:label]

        if selector.valid?
          add_filter(
            :value => selector.sphinx_value,
            :name => selector.filter_name,
            :condition => condition,
            :label => label,
            :sphinx_type => :with,
            :sphinx_attribute => options[:sphinx_attribute] || filter_name,
            :date_selector => selector
          )
        else
          @errors[filter_name.to_sym] = "#{label} is not a valid ."
        end
      end
    end
  end

  def self.define_place_filter(filter_name, options = {})
    attr_reader filter_name

    define_method "#{filter_name}=" do |hsh|
      if hsh.present? && hsh.values.any?(&:present?)
        place_selector = ApplicationSearch::PlaceSelector.new(hsh[:location], hsh[:within])
        instance_variable_set("@#{filter_name}", place_selector)
        if place_selector.valid? && place_selector.location.present?
          add_filter(
            :value => [place_selector.place_ids], # deeply nested array keeps places together to avoid duplicate filters
            :name => "within #{place_selector.within} miles of #{place_selector.location}",
            :condition => filter_name,
            :sphinx_attribute => options[:sphinx_attribute],
            :label => "Located",
            :sphinx_type => :with
          )
        else
          unless place_selector.valid?
            @errors[filter_name] = place_selector.validation_errors
          end
        end
      end
    end
  end

  def initialize(options = {})
    if options.try(:permit!)
      options = options.permit!.to_h.with_indifferent_access
    else
      options = options.with_indifferent_access
    end
    @errors = {}
    @filters = []

    if options[:maximum_per_page].present?
      @maximum_per_page = options[:maximum_per_page].to_i
    else
      @maximum_per_page = 2000
    end

    # Set some defaults...
    @page = options[:page].to_i
    if @page < 1 || @page > 50
      @page = 1
    end

    @excerpts = options.fetch(:excerpts, false)

    set_defaults(options)

    @skip_results = options[:skip_results] || false
    self.per_page = options[:per_page]

    conditions = options[:conditions].blank? ? {} : options[:conditions]
    self.conditions = conditions.reject do |key,val|
      unless self.respond_to?("#{key}=")
        @errors[key] = "is not a valid field"
      end
    end.with_indifferent_access
  end

  def conditions=(conditions)
    return if conditions.blank?

    @conditions = conditions
    @valid_conditions = {}

    Array(conditions).reverse.each do |attr, val|
      next unless self.respond_to?("#{attr}=")

      response = self.send("#{attr}=", val)
      @valid_conditions[attr] = val if response.present?
    end
  end

  def add_filter(options)
    vals = (options[:value].is_a?(Array) ? options[:value] : [options[:value]])
    multi = options[:condition] == :near ? false : options[:value].is_a?(Array)

    vals.each do |val|
      #NOTE: A filter is added for EACH value if it is an array
      @filters << ApplicationSearch::Filter.new(options.merge(value: val, multi: multi))
    end
  end

  def valid?
    @errors.empty?
  end

  def blank?
    [with, with_all, without, sphinx_conditions, term].all?(&:blank?) || skip_results?
  end

  def skip_results?
    @skip_results
  end

  def sphinx_conditions
    sphinx_conditions = {}
    @filters.select{|f| f.sphinx_type == :conditions }.each do |filter|
      sphinx_conditions[filter.sphinx_attribute] = ApplicationSearch::TermPreprocessor.process_term(filter.sphinx_value)
    end

    sphinx_conditions
  end

  def with
    with = {}
    @filters.select{|f| (f.sphinx_type == :with) && !f.date_selector }.each do |filter|
      if filter.multi
        with[filter.sphinx_attribute] ||= []
        Array.wrap(filter.sphinx_value).each do |val|
          with[filter.sphinx_attribute] << val
        end
      else
        with[filter.sphinx_attribute] = filter.sphinx_value
      end
    end
    with
  end

  def es_match_queries
    with = {}
    @filters.select{|f| (f.sphinx_type == :es_match_query) && !f.date_selector }.each do |filter|
      if filter.multi
        with[filter.sphinx_attribute] ||= []
        with[filter.sphinx_attribute] << filter.sphinx_value
      else
        with[filter.sphinx_attribute] = filter.sphinx_value
      end
    end
    with
  end

  def with_for_facets
    #NOTE: .with has changed to exclude filters with a date selector--this method retains them since publication_date options are used when building facets.  At some point we may want to patch strictly the publication date with options directly to the DateAggregator constructor
    with = {}
    @filters.select{|f| f.sphinx_type == :with }.each do |filter|
      if filter.multi
        with[filter.sphinx_attribute] ||= []
        with[filter.sphinx_attribute] << filter.sphinx_value
      else
        with[filter.sphinx_attribute] = filter.sphinx_value
      end
    end
    with
  end

  def without
    without = {}
    @filters.select{|f| f.sphinx_type == :without }.each do |filter|
      without[filter.sphinx_attribute] ||= []
      without[filter.sphinx_attribute] << filter.sphinx_value
    end
    without
  end

  def result_ids(args = {})
    if args.present?
      Honeybadger.notify("Not expecting this method to be invoked with args.")
    end

    ids = []
    after = 0
    loop do
      base_search_options = search_options.merge(
        size: INTERNAL_BATCH_SIZE,
        search_after: [after],
        sort: [ {id: 'asc'} ]
      )
      search_ids = repository.search(base_search_options).results.map(&:id)

      ids += search_ids
      after = search_ids.last

      break if search_ids.count == 0
    end
    ids
  end

  INTERNAL_BATCH_SIZE = 500
  private_constant :INTERNAL_BATCH_SIZE

  class ActiveRecordCollectionMetadataWrapper
    # Used to provide a way for AR collection to respond to former TS collection args (e.g. next_page, previous_page)
    delegate_missing_to :@active_record_collection

    def initialize(es_search_invocation, active_record_collection, page, per_page)
      @es_search_invocation        = es_search_invocation
      @active_record_collection    = active_record_collection
      @page                        = page
      @per_page                    = per_page
    end

    def next_page
      if page < total_pages
        page + 1
      end
    end

    def previous_page
      if page != 1
        page - 1
      end
    end

    def total_pages
      total = (count.to_f / per_page).ceil
      if total > 50 #NOTE: This is a carry-over from ApplicationSearch to get total pages to be within bounds.  See commit #c3f1ead6ff for original context.
        50
      else
        total
      end
    end

    def count
      es_search_invocation.total
    end

    def es_ids
      es_search_invocation.map(&:id)
    end

    def ids
      active_record_collection.pluck(:id)
    end

    private

    attr_reader :es_search_invocation, :active_record_collection, :page, :per_page

  end

  def date_aggregator_buckets
    repository.
      search(aggregation_search_options).
      response.
      aggregations['group_by_publication_date'].
      buckets
  end

  def facet_calculator_buckets
    repository.
      search(facet_calculator_search_options).
      response.
      aggregations['group_by_facet'].
      buckets
  end

  def results(args = {})
    # Retrieve AR ids from Elasticsearch
    es_search_invocation = repository.search(search_options)
    results = es_search_invocation.results

    ar_collection_with_metadata = ActiveRecordCollectionMetadataWrapper.new(es_search_invocation, results, page, per_page)

    if ar_collection_with_metadata && @excerpts
      #NOTE: Formerly the actual AR object was being returned and so we could query the raw_text_updated_at column here, but now we're querying the actual ES document for teh raw_text_updated_at
      results_with_raw_text, results_without_raw_text = ar_collection_with_metadata.partition{|e| e.raw_text_updated_at.present?}

      if results_with_raw_text.present?
        ar_collection_with_metadata.in_groups_of(1024,false).each do |batch|
          begin
            # merge excerpts back to their result
            batch.each_with_index do |result, index|
              result.excerpt = es_search_invocation.results[index].highlights.gsub("...", "…")
            end
          rescue StandardError => e
            #TODO: This standard error rescuing is perhaps too aggressive--ideally we'd want to limit to the specific error in question
            # if we can't read a file we want to still show the search results
            Rails.logger.warn(e)
            Honeybadger.notify(e, context: args)
          end
        end
      end
    end

    ar_collection_with_metadata
  end

  def es_conditions
    es_conditions = {}
    @filters.select{|f| f.sphinx_type == :conditions }.each do |filter|
      #es_conditions[filter.sphinx_attribute] = ApplicationSearch::TermPreprocessor.process_term(filter.sphinx_value)
      es_conditions[filter.sphinx_attribute] = filter.sphinx_value

    end

    es_conditions
  end

  def order_clause
    "@relevance DESC"
  end

  def sort_mode
    :extended
  end

  def find_options
    {}
  end

  def to_hash
    {
      :page => @page,
      :per_page => @per_page,
      :order => order_clause,
      :conditions => conditions
    }
  end

  def count
    @count ||= repository.count(count_search_options)
  end

  def term_count
    sphinx_search_count(sphinx_term, :match_mode => :extended)
  end

  def entry_count
    Entry.search_klass.new(:conditions => {:term => @term}).term_count
  end

  def to_json
    @conditions.to_json
  end

  def sphinx_term
    @sphinx_term ||= ApplicationSearch::TermPreprocessor.process_term(@term)
  end

  def sphinx_search_count(term, options)
    sphinx_retry do
      begin
        model.search_count(term, options)
      rescue ThinkingSphinx::SphinxError
        model.search_count(term, options.merge(:match_mode => :all))
      end
    end
  end

  def sphinx_search(term, options)
    sphinx_retry do
      begin
        results = model.search(term, options)

        # results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane

        # force sphinx to populate the result so that if it fails due to
        #   unescaped invalid extended mode characters we can handle the
        #   error here
        results.send(:populate) if results.is_a?(ThinkingSphinx::Search)

        results
      rescue ThinkingSphinx::SphinxError
        model.search(term, options.merge(:match_mode => :all))
      end
    end
  end

  def es_term
    @es_term ||= TermPreprocessor.process_term(@term)
  end


  private

  attr_reader :aggregation_field, :date_histogram_interval

  def add_agency_information_at_runtime!(results)
    # Augment ES results with lazy-loaded objects using batch-loader gem.  These lazy-loaded objects will be called when the API results are transformed into JSON so we're not N+1'ing when serializing.
    results.each do |result|
      result.agencies
    end
  end

  def batch_load_agency_name(agency_name_id)
    BatchLoader.for(agency_name_id).batch do |agency_name_ids, loader|
      AgencyName.where(id: agency_name_ids).each { |agency_name| loader.call(agency_name.id, agency_name) }
    end
  end

  def es_base_query
    {
      # explain: true, #NOTE: Useful for investigating relevancy calcs.
      size: per_page,
      from: es_from,
      query: {
        function_score: {
          query: {
            bool: {
              must: [],
              filter: []
            }
          },
          functions: es_scoring_functions,
          boost_mode: 'multiply',
        }
      },
      sort: es_sort_order,
      _source: es_source,
    }.tap do |query|
      if excerpts
        query.merge!(highlight: highlight_query)
      end
    end
  end

  def es_source
    {excludes: ["full_text"]}
  end

  def highlight_query
    {
      pre_tags: ['<span class="match">'],
      post_tags: ["</span>"],
      fields:    highlight_fields,
    }
  end

  def highlight_fields
    raise NotImplementedError #no-op
  end

  def es_sort_order
    raise NotImplementedError #No-op
  end

  def es_from
    if page == 1
      0
    else
      ((page - 1) * per_page)
    end
  end

  def aggregation_search_options
    search_options.merge(
      aggregations: {
        "group_by_publication_date": {
          "date_histogram": {
            "field": "publication_date",
            "interval": date_histogram_interval
          },
        }
      }
    )
  end

  TERM_AGGREGATION_SIZE = 1000
  def facet_calculator_search_options
    search_options.merge(
      aggregations: {
        "group_by_facet": {
          "terms": {
            "field": aggregation_field,
            "size": TERM_AGGREGATION_SIZE,
          }
        }
      }
    )
  end

  def count_search_options
    options = search_options.except(:size, :from, :sort, :highlight).dup.tap do |ops|
      ops[:query][:function_score][:functions]= Array.new
      ops.delete(:_source)
    end
  end

  DEFAULT_RESULTS_PER_PAGE = 20
  def search_options
    @page ||= 1
    @per_page ||= DEFAULT_RESULTS_PER_PAGE

    max_resultset = @page * @per_page
    if max_resultset > 10_000
      @page = 1
    end

    # {
      # :page => @page,
      # :per_page => @per_page,
      # :order => order_clause,
      # :with => with,
      # :with_all => with_all,
      # :without => without,
      # :conditions => sphinx_conditions,
      # :match_mode => :extended,
      # :retry_stale => true,
      # :sort_mode => sort_mode,
      # :max_matches => 10_000,
      # :excerpts => {:limit => 300, :around => 150},
    # }.merge(find_options)
    #

    query = es_base_query.tap do |q|
      # Handle term
      if es_term.present?
        q[:query][:function_score][:query][:bool][:should] = [
          {
            simple_query_string: {
              query:            es_term,
              fields:           es_fields_with_boosts,
              default_operator: 'and',
              quote_field_suffix: '.exact'
            }
          }
        ]
        q[:query][:function_score][:query][:bool][:minimum_should_match] = 1
      end

      raise if es_conditions.present?
      es_conditions.each do |(condition, value)|
        q[:query][:function_score][:query][:bool][:must] << {
          bool: {
            must: { # Contributes to score
              term: {
                condition => value
              }
            }
          }
        }
      end

      with.each do |(condition, value)|
        if value.kind_of?(Array) && value.present?
          q[:query][:function_score][:query][:bool][:filter] << {
            bool: {
              filter: {
                terms: {
                  condition => value
                }
              }
            }
          }
        else
          q[:query][:function_score][:query][:bool][:filter] << {
            bool: {
              filter: {
                term: {
                  condition => value
                }
              }
            }
          }
        end
      end

      es_match_queries.each do |(condition, value)|
        q[:query][:function_score][:query][:bool][:filter] << {
          bool: {
            filter: {
              match_phrase: {
                condition => {
                  query: value,
                }
              }
            }
          }
        }
      end

      with_date.each do |condition, date_conditions|
        q[:query][:function_score][:query][:bool][:filter] << {
          range: {
            condition => date_conditions
          }
        }
      end

      with_range.each do |condition, range_conditions|
        q[:query][:function_score][:query][:bool][:filter] << {
          range: {
            condition => range_conditions
          }
        }
      end

    end

    query
  end

  def es_scoring_functions
    [
      {
        "gauss": {
            "publication_date": {
                "origin": "now",
                "scale":  "365d",
                "offset": "30d",
                "decay":  "0.5" #0.5 is the default
            }
        },
      }
    ]
  end

  def with_date
    hsh = {}
    @filters.
      select{|f| f.date_selector }.
      each do |filter|
        hsh[filter.sphinx_attribute] = filter.date_selector.date_conditions
      end
    hsh
  end

  def with_range
    hsh = {}
    @filters.
      select{|f| f.range_conditions }.
      each do |filter|
        hsh[filter.sphinx_attribute] = filter.range_conditions
      end
    hsh
  end

  def set_defaults(options)
    #no-op
  end

  def sphinx_retry
    retry_delays = [0.1, 0.25, 0.5]
    begin
      yield
    rescue Riddle::ResponseError => e
      retry_delay = retry_delays.shift
      if retry_delay
        puts "sleeping for #{retry_delay}"
        sleep(retry_delay)
        retry
      else
        puts "no more attempts"
        raise e
      end
    end
  end

  def es_fields_with_boosts
    raise NotImplementedError #no-op
  end

end

class EsApplicationSearch
  include Rails.application.routes.url_helpers
  extend Memoist
  class InputError < StandardError; end

  attr_accessor :order
  attr_writer :aggregation_field, :date_histogram_interval
  attr_reader :filters, :term, :maximum_per_page, :per_page, :page, :conditions, :valid_conditions, :excerpts, :include_pre_1994_docs

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
            :value => selector.es_value,
            :name => selector.filter_name,
            :condition => condition,
            :label => label,
            :es_type => :with,
            :es_attribute => options[:es_attribute] || filter_name,
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
            :es_attribute => options[:es_attribute],
            :label => "Located",
            :es_type => :with
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
    @include_pre_1994_docs = options.fetch(:include_pre_1994_docs, false)
    default_search_type_ids = [default_search_type.id]
    search_types = (options.dig("conditions", "search_type_ids") || default_search_type_ids).map{|id| SearchType.find(id)}
    raise NotImplementedError if search_types.count != 1 # Originally, the search interface was conceived as being multi-select, but as the infrastructure developed, it started to make more sense to have a search be associated with a single search type
    @search_type = search_types.first

    set_defaults(options)

    @skip_results = options[:skip_results] || false
    self.per_page = options[:per_page]

    conditions = options[:conditions].blank? ? {} : options[:conditions]
    self.conditions = conditions.reject do |key,val|
      unless self.respond_to?("#{key}=") || (key == "search_type_ids")
        @errors[key] = "is not a valid field"
      end
    end.with_indifferent_access

    if options[:facet] == 'daily' && options[:conditions].blank?
      @errors[:facet] =  "More than 10,000 days of grouping were requested.  Please limit your request."
    end
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
    [with, with_all, without, es_conditions, term].all?(&:blank?) || skip_results?
  end

  def skip_results?
    @skip_results
  end

  def es_conditions
    es_conditions = {}
    @filters.select{|f| f.es_type == :conditions }.each do |filter|
      es_conditions[filter.es_attribute] = ApplicationSearch::TermPreprocessor.process_term(filter.es_value)
    end

    es_conditions
  end

  def with
    with = {}
    @filters.select{|f| (f.es_type == :with) && !f.date_selector }.each do |filter|
      if filter.multi
        with[filter.es_attribute] ||= []
        with[filter.es_attribute] << filter.es_value
      else
        with[filter.es_attribute] = filter.es_value
      end
    end
    with
  end

  def es_match_queries
    with = {}
    @filters.select{|f| (f.es_type == :es_match_query) && !f.date_selector }.each do |filter|
      if filter.multi
        with[filter.es_attribute] ||= []
        with[filter.es_attribute] << filter.es_value
      else
        with[filter.es_attribute] = filter.es_value
      end
    end
    with
  end

  def with_for_facets
    #NOTE: .with has changed to exclude filters with a date selector--this method retains them since publication_date options are used when building facets.  At some point we may want to patch strictly the publication date with options directly to the DateAggregator constructor
    with = {}
    @filters.select{|f| f.es_type == :with }.each do |filter|
      if filter.multi
        with[filter.es_attribute] ||= []
        with[filter.es_attribute] << filter.es_value
      else
        with[filter.es_attribute] = filter.es_value
      end
    end
    with
  end

  def without
    without = {}
    @filters.select{|f| f.es_type == :without }.each do |filter|
      without[filter.es_attribute] ||= []
      without[filter.es_attribute] << filter.es_value
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
    if search_type.is_hybrid_search && neural_search_appropriate?
      es_search_invocation = repository.search(hybrid_search_options)
    else
      es_search_invocation = repository.search(search_options)
    end

    results = es_search_invocation.results

    ar_collection_with_metadata = ActiveRecordCollectionMetadataWrapper.new(es_search_invocation, results, page, per_page)
  
    if explain_results?
      explanations = es_search_invocation.raw_response.dig("hits","hits")
      ar_collection_with_metadata.each_with_index do |result, i|
        if search_type.supports_explain
          result.explanation = explanations[i].fetch("_explanation")
        else
          #Hybrid searches do not support/will fail if the _explanation parameter is included.  In these cases, create our own explanation based on the score value given the basic data we have available
          result.explanation = {
            value: explanations[i].fetch("_score"),
          }
        end
      end
    end

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
    @filters.select{|f| f.es_type == :conditions }.each do |filter|
      #es_conditions[filter.sphinx_attribute] = ApplicationSearch::TermPreprocessor.process_term(filter.sphinx_value)
      es_conditions[filter.es_attribute] = filter.es_value

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
    if index_has_neural_querying_enabled? && search_type.is_hybrid_search && es_term.present?
      @count ||= repository.
        search(hybrid_search_count_options).
        raw_response.
        fetch("hits").
        fetch("total").
        fetch("value")
    else  
      @count ||= repository.count(count_search_options)
    end
  end

  def term_count
    es_search_count(es_term, :match_mode => :extended)
  end

  def entry_count
    Entry.search_klass.new(:conditions => {:term => @term}).term_count
  end

  def to_json
    @conditions.to_json
  end

  def es_term
    @es_term ||= ApplicationSearch::TermPreprocessor.process_term(@term)
  end

  def es_search_count(term, options)
    raise NotImplementedError
    es_retry do
      begin
        model.search_count(term, options)
      rescue ThinkingSphinx::SphinxError
        model.search_count(term, options.merge(:match_mode => :all))
      end
    end
  end

  def es_search(term, options)
    es_retry do
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

  attr_reader :aggregation_field, :date_histogram_interval, :search_type

  def default_search_type
    SearchType::HYBRID
  end

  def neural_search_appropriate?
    # It doesn't make to employ a neural search if there's no relationship between the words to derive
    es_term.present? && !advanced_search?
  end

  COMPLEX_SEARCH_CHARACTERS = ['|','&','!','(',')']
  def advanced_search?
    es_term.present? && COMPLEX_SEARCH_CHARACTERS.any?{|char| es_term.include?(char) }
  end

  def es_base_query
    {
      size: per_page,
      from: es_from,
      query: {
        function_score: {
          query: {
            bool: {
              must: es_base_must_conditions,
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
      if explain_results? && search_type.supports_explain
        query.merge!(explain: true) #NOTE: Useful for investigating relevancy calcs
      end

      if excerpts
        query.merge!(highlight: highlight_query)
      end
    end
  end

  def explain_results?
    Settings.feature_flags.explain_query_results
  end

  def es_base_must_conditions
    raise NotImplementedError
  end

  def es_source
    {excludes: ["full_text", "full_text_embedding"]}
  end

  def highlight_query
    {
      highlight_query: simple_query_string, #NOTE: It's necessary to specify this option to ensure the highlights work since the simple_query_string is now nested inside script_score keys.
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

  def hybrid_search_count_options
    #TODO: This can likely be further optimized, perhaps by not sending to the normalization pipeline, removing gaussian decay via function scoring, etc.  Hybrid search does not appear to be supported using the OpenSearch _count endpoint
    hybrid_search_options.except(:explain).dup.tap do |options|
      options["_source"] = false #ie don't return the object attributes
    end
  end

  def count_search_options
    search_options.except(:size, :from, :sort, :highlight, :explain).dup.tap do |ops|
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
      # :conditions => es_conditions,
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

  def hybrid_search_options
    base_query_options = search_options.except(:query)
    function_score_wrapped_lexical_query = search_options[:query]
    function_score_wrapped_neural_query  = search_options[:query]
    function_score_wrapped_neural_query[:function_score][:query][:bool][:should] = [neural_query]

    if search_type.min_function_score_for_neural_query
      function_score_wrapped_neural_query[:function_score].merge!(min_score: search_type.min_function_score_for_neural_query)
    end

    {
      :query => {
        :hybrid => {
          :queries => [
            function_score_wrapped_lexical_query,
            function_score_wrapped_neural_query
          ]
        }
      }
    }.tap do |options|
      options.merge!(base_query_options)
      options.merge!(
        search_pipeline: search_type.search_pipeline_configuration
      )
    end
  end

  def lexical_query
    {
      simple_query_string: {
        query:            es_term,
        fields:           es_fields_with_boosts,
        default_operator: 'and',
        quote_field_suffix: '.exact'
      }
    }
  end

  def neural_query
    {
      "nested": {
        "score_mode": "max",
        "path": "full_text_chunk_embedding",
        "query": {
          "neural": {
            "full_text_chunk_embedding.knn": {
              "query_text": es_term,
              "model_id": text_embedding_model_id,
            }.tap do |knn_config|
              if search_type.k_nearest_neighbors
                knn_config.merge!("k": search_type.k_nearest_neighbors)
              end

              if search_type.min_score
                knn_config.merge!("min_score": search_type.min_score)
              end
            end
          }
        }
      }
    }
  end

  def simple_query_string
    {
      :simple_query_string=> {
        :query=> es_term,
        :fields=>["title^2.5", "full_text^1.25", "agency_name^1", "abstract^2", "docket_id^1", "regulation_id_number^1"], 
        :default_operator=>"and",
        :quote_field_suffix=>".exact"
      }
    }
  end


  def neural_querying_enabled?
    raise NotImplementedError
  end

  def text_embedding_model_id
    OpenSearchMlModelRegistrar.model_id
  end

  def es_scoring_functions
    if search_type.decay
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
    else
      []
    end
  end

  def with_date
    hsh = {}
    @filters.
      select{|f| f.date_selector }.
      each do |filter|
        hsh[filter.es_attribute] = filter.date_selector.date_conditions
      end
    hsh
  end

  def with_range
    hsh = {}
    @filters.
      select{|f| f.range_conditions }.
      each do |filter|
        hsh[filter.es_attribute] = filter.range_conditions
      end
    hsh
  end

  def set_defaults(options)
    #no-op
  end

  def es_retry
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

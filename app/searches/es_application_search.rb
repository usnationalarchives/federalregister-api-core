class EsApplicationSearch
  extend Memoist
  class InputError < StandardError; end

  attr_accessor :order
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
        rescue ApplicationSearch::InputError => e
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

          # add_range_filter(selector)

          add_filter(
            #TODO: Potentially pass in an option indicating this is an ES range query?
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
        place_selector = PlaceSelector.new(hsh[:location], hsh[:within])
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
        with[filter.sphinx_attribute] << filter.sphinx_value
      else
        with[filter.sphinx_attribute] = filter.sphinx_value
      end
    end
    with
  end

  def with_all
    with = {}
    @filters.select{|f| f.sphinx_type == :with_all }.each do |filter|
      with[filter.sphinx_attribute] ||= []
      with[filter.sphinx_attribute] << filter.sphinx_value
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
    sphinx_search(sphinx_term,
      search_options.merge(:ids_only => true).recursive_merge(args)
    )
  end

  def chainable_results(args = {})
    model.
      where(id: result_ids(args)).
      recursive_merge(args.slice(:joins, :includes, :select))
  end

  class ResultArray #TODO: Change this name
    delegate_missing_to :@active_record_collection

    def initialize(es_search_invocation, active_record_collection)
      @es_search_invocation        = es_search_invocation
      @active_record_collection    = active_record_collection
    end

    def next_page
      #TODO
    end

    def previous_page
      #TODO
    end

    def count
      es_search_invocation.total
    end

    def total_pages
      0 #TODO: Fix
    end

    def es_ids
      es_search_invocation.map{|x| x.fetch('id') }
    end

    def ids
      active_record_collection.pluck(:id)
    end

    private

    attr_reader :es_search_invocation, :active_record_collection

  end

  def results(args = {})
    select = args.delete(:select)
    args.merge!(sql: {select: select})

    # Retrieve AR ids from Elasticsearch
    es_search_invocation = repository.search(search_options)

    # Get AR objects
    active_record_collection = model.where(id: es_search_invocation.results.map{|x| x.try(:id) || x.fetch('id')} ) #TODO: Currently we're calling the safe operator on the result object because Pi results are wrapped and Entry results are not wrapped.  We'll want to standardize this interface so we're not calling it two separate ways.

    # TODO: replace model?
    # TODO: i think this needs to get pushed into the ResultArray and pagination will have to be handled there, since es_search_invocation currently deals with a single page of results
    # active_record_collection = args[:model_scope].where(id: es_search_invocation.results.map(&:id))

    # Provide a way for collection to respond to former TS collection args (e.g. next_page, previous_page)
    result_array = ResultArray.new(es_search_invocation, active_record_collection)


    if result_array && @excerpts
      results_with_raw_text, results_without_raw_text = result_array.partition{|e| e.raw_text_updated_at.present?}

      if results_with_raw_text.present?
        results_with_raw_text.in_groups_of(1024,false).each do |batch|
          begin
            # merge excerpts back to their result
            # batch.each_with_index do |result, index|
            #   result.excerpt = result.excerpts.send(result.method_or_attribute_for_thinking_sphinx_excerpting)
            # end
          rescue Riddle::ResponseError => e
            # if we can't read a file we want to still show the search results
            Rails.logger.warn(e)
            Honeybadger.notify(e)
          end
        end
      end

      # no abstracts for pil documents so nothing to do for those
      if model == Entry
        # missing raw text but we want the abstract term matches highlighted
        results_without_raw_text.each do |result|
          result.excerpt = result.excerpts.abstract
        end
      else
        raise "#{model} not supported"
      end
    end

    # TODO: FIXME: Ugly hack to get total pages to be within bounds
    if result_array && result_array.total_pages > 50
      def result_array.total_pages
        50
      end
    end

    result_array
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
    @count ||= sphinx_search_count(sphinx_term,
      search_options.except(:order, :sort_mode)
    )
  end

  def term_count
    sphinx_search_count(sphinx_term, :match_mode => :extended)
  end

  def entry_count
    EntrySearch.new(:conditions => {:term => @term}).term_count
  end

  def public_inspection_document_count
    PublicInspectionDocumentSearch.new(:conditions => {:term => @term}).term_count
  end

  def event_count
    EventSearch.new(:conditions => {:term => @term}).term_count
  end

  def regulatory_plan_count
    RegulatoryPlanSearch.new(:conditions => {:term => @term}).term_count
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
        #TODO: REIMPLEMENT EXCERPTING HERE

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
    @es_term ||= @term
  end


  private

  def es_base_query
    {
      size: per_page,
      from: es_from,
      query: {
        bool: {
          must: [
            # es_query_string_query
          ],
          filter: []
        }
      },
      sort: es_sort_order
    }
  end

  def es_sort_order
    raise NotImplementedError #No-op
  end

  def es_query_string_query
    {
      "query_string": {
        "query": "magic schoolbus"
      }
    }
  end

  def es_from
    from = (page - 1) * per_page
    if from != 0
      from + 1
    else
      from
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

    #TODO: handle term, sql_args
    query = es_base_query.tap do |q|
      # Handle term
      if es_term.present?
        q[:query][:bool][:should] = [
          {
            simple_query_string: {
              query:            es_term,
              fields:           ['title', 'full_text', 'agency_name'],
              default_operator: 'and'
            }
          }
        ]
        q[:query][:bool][:minimum_should_match] = 1
      end

      raise if es_conditions.present?
      es_conditions.each do |(condition, value)|
        q[:query][:bool][:must] << {
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
          q[:query][:bool][:filter] << {
            bool: {
              filter: {
                terms: {
                  condition => value
                }
              }
            }
          }
        else
          q[:query][:bool][:filter] << {
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

      with_date.each do |condition, date_conditions|
        q[:query][:bool][:filter] <<
        {
          range: {
            condition => date_conditions
          }
        }
      end
    end

    query
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

  def set_defaults(options)
    raise NotImplementedError
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
end

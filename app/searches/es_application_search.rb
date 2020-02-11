class EsApplicationSearch
  attr_reader :conditions, :filters, :per_page, :term

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

  def results(args = {})
    select = args.delete(:select)
    args.merge!(sql: {select: select})

    result_array = es_search(es_term,
      search_options.recursive_merge(args)
    )

    # if result_array && @excerpts
      # results_with_raw_text, results_without_raw_text = result_array.partition{|e| e.raw_text_updated_at.present?}

      # if results_with_raw_text.present?
        # results_with_raw_text.in_groups_of(1024,false).each do |batch|
          # begin
            # # merge excerpts back to their result
            # batch.each_with_index do |result, index|
              # result.excerpt = result.excerpts.send(result.method_or_attribute_for_thinking_sphinx_excerpting)
            # end
          # rescue Riddle::ResponseError => e
            # # if we can't read a file we want to still show the search results
            # Rails.logger.warn(e)
            # Honeybadger.notify(e)
          # end
        # end
      # end

      # # no abstracts for pil documents so nothing to do for those
      # if model == Entry
        # # missing raw text but we want the abstract term matches highlighted
        # results_without_raw_text.each do |result|
          # result.excerpt = result.excerpts.abstract
        # end
      # end
    # end

    # # TODO: FIXME: Ugly hack to get total pages to be within bounds
    # if result_array && result_array.total_pages > 50
      # def result_array.total_pages
        # 50
      # end
    # end

    result_array
  end

  def es_conditions
    # WIP
    {}
  end

  def with
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

  # def with_all
    # with = {}
    # @filters.select{|f| f.sphinx_type == :with_all }.each do |filter|
      # with[filter.sphinx_attribute] ||= []
      # with[filter.sphinx_attribute] << filter.sphinx_value
    # end
    # with
  # end

  # def without
    # without = {}
    # @filters.select{|f| f.sphinx_type == :without }.each do |filter|
      # without[filter.sphinx_attribute] ||= []
      # without[filter.sphinx_attribute] << filter.sphinx_value
    # end
    # without
  # end

  def order_clause
    "@relevance DESC"
  end

  def find_options
    {}
  end

  private

  def es_search(term, options)
    results = $public_inspection_document_repository.search(term)
  end

  def es_term
    @term = ""
    @es_term ||= ApplicationSearch::TermPreprocessor.process_term(@term)
  end

  def set_defaults(options)
    # No-op
  end

  def search_options
    @page ||= 1
    @per_page ||= 20

    max_resultset = @page * @per_page
    if max_resultset > 10_000
      @page = 1
    end

    {
      :page => @page,
      :per_page => @per_page,
      :order => order_clause,
      :with => with,
      # :with_all => with_all,
      # :without => without,
      # :conditions => es_conditions,
      # :match_mode => :extended,
      # :retry_stale => true,
      # :sort_mode => sort_mode,
      # :max_matches => 10_000,
      # :excerpts => {:limit => 300, :around => 150},
    }.merge(find_options)
  end

end

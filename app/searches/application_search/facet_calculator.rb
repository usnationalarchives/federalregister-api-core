class ApplicationSearch::FacetCalculator
  def initialize(options)
    @search = options[:search]
    @model = options[:model]
    @hash = options[:hash]
    @facet_name = options[:facet_name]
    @name_attribute = options[:name_attribute] || :name
    @identifier_attribute = options[:identifier_attribute]
  end

  def raw_facets
    results = @search.es_search(
      @search.es_term,
      :with => @search.with,
      :with_all => @search.with_all,
      :conditions => @search.es_conditions,
      :match_mode => :extended,
      :per_page => 1000,
      :group_by => @facet_name.to_s,
      :ids_only => true
    )
    counts = []
    results.each_with_group_and_count{|entry, group_id, count| counts << [group_id, count]}
    counts
  end

  def all
    if @model
      if @model.active_hash?
        id_to_name = @model.find_as_hash(:select => "id, #{@name_attribute}")
        id_to_identifier = @model.find_as_hash(:select => "id, #{@identifier_attribute}")
      else
        id_to_name_sql = @model.select("id, #{@name_attribute}").to_sql
        id_to_name = @model.find_as_hash(id_to_name_sql)

        if @identifier_attribute
          id_to_identifier_sql = @model.select("id, #{@identifier_attribute}").to_sql
          id_to_identifier = @model.find_as_hash(id_to_identifier_sql)
        else
          id_to_identifier = {}
        end
      end

      search_value_for_this_facet = @search.send(@facet_name)
      facets = raw_facets.reverse.reject{|id, count| id == 0}.map do |id, count|
        name = id_to_name[id]

        next if name.blank?
        ApplicationSearch::Facet.new(
          :value      => id,
          :identifier => id_to_identifier[id],
          :name       => name,
          :count      => count,
          :on         => Array(search_value_for_this_facet).include?(id),
          :condition  => @facet_name
        )
      end
    else
      facets = raw_facets.reverse.reject{|id, count| id == 0}.map do |id, count|
        value = @hash.keys.find{|k| Zlib.crc32(k) == id}
        next if value.blank?
        ApplicationSearch::Facet.new(
          :value      => value,
          :name       => @hash[value] || value,
          :count      => count,
          :on         => value.to_s == search_value_for_this_facet.to_s,
          :condition  => :type
        )
      end
    end
    facets = facets.compact
    facets.sort_by{|f| [0-f.count, f.name]}
  end
end

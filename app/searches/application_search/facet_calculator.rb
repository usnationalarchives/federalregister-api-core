class ApplicationSearch::FacetCalculator
  def initialize(options)
    @search = options[:search]
    @model = options[:model]
    @hash = options[:hash]
    @facet_name = options[:facet_name]
    @name_attribute = options[:name_attribute] || :name
  end
  
  def raw_facets
    sphinx_search = ThinkingSphinx::Search.new(@search.term,
      :with => @search.with,
      :with_all => @search.with_all,
      :conditions => @search.sphinx_conditions,
      :match_mode => :extended,
      :classes => [@search.model]
    )
    
    client = sphinx_search.send(:client)
    client.group_function = :attr
    client.group_by = @facet_name.to_s
    client.limit = 5000
    query = sphinx_search.send(:query)
    result = client.query(query, sphinx_search.send(:indexes))[:matches].map{|m| [m[:attributes]["@groupby"], m[:attributes]["@count"]]}
  end
  
  def all
    if @model
      id_to_name = @model.find_as_hash(:select => "id, #{@name_attribute} AS name")#, :conditions => {:id => raw_facets.keys})
      search_value_for_this_facet = @search.send(@facet_name)
      facets = raw_facets.reverse.reject{|id, count| id == 0}.map do |id, count|
        name = id_to_name[id.to_s]
        next if name.blank?
        Facet.new(
          :value      => id,
          :name       => name,
          :count      => count,
          :on         => search_value_for_this_facet.to_a.include?(id.to_s),
          :condition  => @facet_name
        )
      end
    else
      facets = raw_facets.reverse.reject{|id, count| id == 0}.map do |id, count|
        value = @hash.keys.find{|k| k.to_crc32 == id}
        next if value.blank?
        Facet.new(
          :value      => value,
          :name       => @hash[value],
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

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
    @search.sphinx_search(
      @search.sphinx_term,
      :with => @search.with,
      :with_all => @search.with_all,
      :conditions => @search.sphinx_conditions,
      :match_mode => :extended,
      :per_page => 1000,
      :group => @facet_name.to_s,
      :ids_only => true
    ).results[:matches].map{|m| [m[:attributes]["@groupby"], m[:attributes]["@count"]]}
  end
  
  def all
    if @model
      id_to_name = @model.find_as_hash(:select => "id, #{@name_attribute}")

      if @identifier_attribute
        id_to_identifier = @model.find_as_hash(:select => "id, #{@identifier_attribute}")
      else
        id_to_identifier = {}
      end

      search_value_for_this_facet = @search.send(@facet_name)
      facets = raw_facets.reverse.reject{|id, count| id == 0}.map do |id, count|
        name = id_to_name[id.to_s]

        next if name.blank?
        ApplicationSearch::Facet.new(
          :value      => id,
          :identifier => id_to_identifier[id.to_s],
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

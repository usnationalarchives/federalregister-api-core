module FrIndexPresenter
  class AgencyPresenter
    attr_reader :agency, :total_count
    attr_accessor :children

    delegate :id,
             :name,
             :parent_id,
             :slug,
             :to_param,
             :to => :agency

    def initialize(agency, total_count)
      @agency = agency
      @total_count = total_count
    end

    def entries_count
      @total_count
    end
  end

  def self.agencies_in_year(year)
    facets = EntrySearch.new(
      :conditions => {:publication_date => {:year => year}}
    ).agency_facets

    agencies = Agency.all(:conditions => {:id => facets.map(&:value)}, :include => :children).to_a

    agency_presenters = facets.map do |facet|
      AgencyPresenter.new(agencies.detect{|a| a.id == facet.value}, facet.count)
    end

    agency_presenters.each do |p|
      p.children = agency_presenters.select{|c| c.parent_id == p.id}.sort_by{|c| c.name.downcase}
    end
    
    agency_presenters.sort_by{|a| a.name.downcase}
  end

  def self.grouped_entries_for_year_and_agency(year, agency)
    first = Date.parse('1900-01-01')

    entries = agency.entries.scoped(
      :select => "entries.id, entries.document_number, entries.publication_date, entries.title, entries.toc_subject, entries.toc_doc",
      :conditions => {:publication_date => Date.parse("#{year}-01-01")..Date.parse("#{year}-12-31")})
    entries.group_by(&:entry_type).sort_by{|type,entries| type}.reverse.map do |type, entries_by_type|

      entries_with_toc_subject, entries_without_toc_subject = entries_by_type.partition{|e| e.toc_subject.present?}

      grouped_entries = entries_with_toc_subject.group_by(&:toc_subject).map do |toc_subject, entries_by_toc_subject|
        [toc_subject] << entries_by_toc_subject.group_by do |e|
          (e.toc_doc || e.title)
        end.sort_by{|a,b| a.downcase}.map{|a,b| [a,b.sort_by(&:publication_date)]}
      end

      grouped_entries += entries_without_toc_subject.group_by(&:title).map{|g_e| [nil, [[g_e.first, g_e.second.sort_by(&:publication_date)]]]}

      sorted_grouped_entries = grouped_entries.sort_by{|a,b| [a || b.first.first]}
      [type, sorted_grouped_entries]
    end
  end
end

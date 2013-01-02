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
      agency = agencies.detect{|a| a.id == facet.value}
      if agency.children.present?
        count = EntrySearch.new(:conditions => {
          :publication_date => {:year => year},
          :agency_ids => [agency.id],
          :without_agency_ids => agency.children.map(&:id)
        }).count
      else
        count = facet.count
      end
      AgencyPresenter.new(agency, count)
    end

    agency_presenters.each do |p|
      p.children = agency_presenters.select{|c| c.parent_id == p.id}.sort_by{|c| c.name.downcase}
    end
    
    agency_presenters.sort_by{|a| a.name.downcase}
  end

  def self.entries_for_year_and_agency(year,agency)
    EntrySearch.new(
      :conditions => {
        :agency_ids => [agency.id] + agency.children.map(&:id),
        :publication_date => {
          :gte => Date.parse("#{year}-01-01"),
          :lte => Date.parse("#{year}-12-31"),
        }
      },
      :per_page => 1000
    ).raw_results(
      :select => %w(
        id
        document_number
        publication_date
        title
        toc_subject
        toc_doc
        fr_index_subject
        fr_index_doc
        granule_class
        start_page
        
        presidential_document_type_id
        executive_order_number
      ).map{|attribute| "entries.#{attribute}"}.join(",")
    )
  end

  def self.grouped_entries_for_year_and_agency(year, agency)
    entries = entries_for_year_and_agency(year,agency)

    entries.group_by(&:granule_class).sort_by{|type,entries| type}.reverse.map do |type, entries_by_type|

      entries_with_subject, entries_without_subject = entries_by_type.partition{|e| e.fr_index_subject.present?}

      grouped_entries = entries_with_subject.group_by(&:fr_index_subject).map do |subject, entries_by_subject|
        [subject] << entries_by_subject.group_by do |e|
          (e.fr_index_doc || e.title)
        end.sort_by{|a,b| a.downcase}.map{|a,b| [a,b.sort_by(&:publication_date)]}
      end

      grouped_entries += entries_without_subject.group_by(&:title).map{|g_e| [nil, [[g_e.first, g_e.second.sort_by(&:publication_date)]]]}

      sorted_grouped_entries = grouped_entries.sort_by{|a,b| [a || b.first.first]}
      [type, sorted_grouped_entries]
    end
  end
end

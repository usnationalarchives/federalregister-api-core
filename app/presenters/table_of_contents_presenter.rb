class TableOfContentsPresenter
  class AgencyPresenter
    attr_reader :agency, :entries, :entry_count
    delegate :name, :slug, :to_param, :to => :agency

    def initialize(toc_view, agency)
      @toc_view = toc_view
      @agency = agency
      @entries = []
    end

    def add_entry(entry)
      @entries << entry
    end

    def children
      @children ||= @toc_view.agencies.select{|a| agency.children.include?(a.agency) }
    end

    def entry_count
      @entry_count ||= entries.size + children.sum(&:entry_count)
    end
    
    def entries_by_type_and_toc_subject
      entries.group_by(&:category).sort_by{|category, entries| category }.reverse.map do |category, entries_by_type|
        entries_by_toc_subject = []

        entries_by_type.
          group_by(&:toc_subject).
          each do |toc_subject, subject_entries|
            if toc_subject.present?
              entries_by_toc_subject << [
                toc_subject,
                subject_entries.sort_by{|e| [e.toc_doc.try(:downcase) || '', (e.toc_doc || e.title).downcase]}
              ]
            else
              # if an item doesn't have a toc_subject, put in own array
              #   so can be mixed in with the TOC subjects
              subject_entries.each do |ungrouped_entry|
                entries_by_toc_subject << [nil, [ungrouped_entry]]
              end
            end
          end

        # sort all the groupings, mixing together ones with and without TOC subjects
        entries_by_toc_subject = entries_by_toc_subject.
          sort_by do |toc_subject, subject_entries|
            [
              toc_subject,
              subject_entries.first.toc_doc,
              subject_entries.first.title
            ].reject(&:blank?).first.downcase
          end

        [category, entries_by_toc_subject]
      end
    end
    
  end

  attr_accessor :entries_without_agencies, :agencies, :agency_ids, :entries_with_agencies, :entries
  def initialize(entries, options = {})
    @entries = entries
    @entries_without_agencies, @entries_with_agencies =  entries.sort_by{|e| [e.start_page || 0, e.end_page || 0, e.id]}.partition{|e| e.agencies.blank? }

    agencies_hsh = {}
    @entries_with_agencies.each do |entry|
      # create entry views for all associated agencies, powering the 'See XXX'
      entry.agencies.each do |agency|
        agencies_hsh[agency.id] ||= AgencyPresenter.new(self, agency)
        if options[:always_include_parent_agencies] && agency.parent.present?
          agencies_hsh[agency.parent_id] ||= AgencyPresenter.new(self, agency.parent)
        end
      end
      
      entry.agencies.excluding_parents.each do |agency|
        agencies_hsh[agency.id].add_entry(entry)
      end
    end
    
    # generate list of agencies, downcasing to sort appropriately (eg 'Health and Human...' before 'Health Resources...')
    @agencies = agencies_hsh.values.sort_by{|a| a.name.downcase}
    
    # preload all child agencies for performance
    Agency.preload_associations(@agencies.map(&:agency), :children)
  end

  def entry_count
    @entry_count ||= @entries.size
  end
end

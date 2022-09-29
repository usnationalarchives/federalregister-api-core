class AgencyName < ApplicationModel
  include CacheUtils
  belongs_to :agency
  has_many :agency_name_assignments
  has_many :entries, :through => :agency_name_assignments
  has_many :public_inspection_documents, :through => :agency_name_assignments

  validates_presence_of :name
  validate :does_not_have_agency_if_void

  before_create :assign_agency_if_exact_match
  after_save :update_agency_assignments
  after_save :update_agency_entries_count
  scope :unprocessed, -> { where(void: false, agency_id: nil).order("agency_names.name") }

  def self.find_or_create_by_name(name)
    cleaned_name = name.sub(/\W+$/, '')
    find_by_name(cleaned_name) || create(:name => cleaned_name)
  end

  def unprocessed?
    (!void?) && agency_id.nil?
  end

  private

  def update_agency_assignments
    if saved_change_to_agency_id?

      # mark entries as changed
      if entry_ids.present?
        EntryChange.upsert_all(entry_ids.map{|id| {entry_id: id} })
        ElasticsearchIndexer.handle_entry_changes
      end

      recompile_associated_tables_of_contents
      recompile_public_inspection_tables_of_contents

      purge_cache(".*")
    end
  end

  def recompile_public_inspection_tables_of_contents
    public_inspection_dates.each{|date| Sidekiq::Client.enqueue(PublicInspectionTableOfContentsRecompiler, date) }
  end

  def public_inspection_dates
    public_inspection_documents.map(&:public_inspection_issues).flatten.map(&:publication_date).uniq
  end

  def recompile_associated_tables_of_contents
    entries.
      select("DISTINCT(publication_date)").
      each{|entry| Sidekiq::Client.enqueue(TableOfContentsRecompiler, entry.publication_date) }
  end

  def does_not_have_agency_if_void
    errors.add(:agency_id, "must be blank if void") if (void? && agency_id.present?)
  end

  def assign_agency_if_exact_match
    agency = Agency.find_by_name(name) || Agency.find_by_name(alternative_name)
    if agency
      self.agency = agency
    end

    true
  end

  def alternative_name
    alternative_name = name.dup
    alternative_name.gsub!(/(?:U\b\.?S\b\.?|united states)/i, '') # remove U.S.

    # remove parentheticals
    alternative_name.sub!(/\(.*\)/, '')
    alternative_name.sub!(/\[.*\]/, '')
    alternative_name.sub!(/\\\\.*/, '')

    # remove semicolons on
    alternative_name.sub!(/;.*/,'')

    # remove parens on
    alternative_name.sub!(/\(.*/,'')

    # cleanup whitespace
    alternative_name.gsub!(/ {2,}/, ' ')
    alternative_name.gsub!(/^ /, '')
    alternative_name.gsub!(/ $/, '')

    alternative_name.sub!(/^(\w+) (?:of|on|for)(?: the)? (.*)/i, '\2 \1')

    alternative_name
  end

  def update_agency_entries_count
    if saved_change_to_agency_id?
      if agency_id_before_last_save.present?
        Agency.find(agency_id_before_last_save).recalculate_entries_count!
      end
      if agency
        agency.recalculate_entries_count!
      end
    end
    true
  end
end

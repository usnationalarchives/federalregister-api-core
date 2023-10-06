# require 'flickr'
class Entry < ApplicationModel
  self.inheritance_column = nil
  include EntryViewLogic
  include CacheUtils
  extend ActiveHash::Associations::ActiveRecordExtensions

  include TextHelper
  attr_writer :excerpt

  GPO_PDF_START_DATE = Date.new(1995,1,3)

  DESCRIPTIONS = {
    :notice => 'This section of the Federal Register contains documents other than rules
                or proposed rules that are applicable to the public. Notices of hearings
                and investigations, committee meetings, agency decisions and rulings,
                delegations of authority, filing of petitions and applications and agency
                statements of organization and functions are examples of documents
                appearing in this section.'
  }

  ENTRY_TYPES = {
    'RULE'     => 'Rule',
    'PRORULE'  => 'Proposed Rule',
    'NOTICE'   => 'Notice',
    'PRESDOCU' => 'Presidential Document',
    'CORRECT'  => 'Correction',
    'UNKNOWN'  => 'Uncategorized Document',
    'SUNSHINE' => 'Sunshine Act Document'
  }

  belongs_to :issue, :foreign_key => :publication_date, :primary_key => :publication_date
  belongs_to :presidential_document_type
  belongs_to :action_name
  belongs_to :correction_of, :class_name => "Entry"
  belongs_to :regs_dot_gov_docket, :foreign_key => :regulations_dot_gov_docket_id

  has_one :public_inspection_document
  has_one :entry_change

  has_many :corrections, :foreign_key => "correction_of_id", :class_name => "Entry"
  has_many :regs_dot_gov_documents, -> { active }, primary_key: :document_number, foreign_key: :federal_register_document_number
  has_many :regs_dot_gov_dockets, through: :regs_dot_gov_documents
  has_many :topic_name_assignments, :dependent => :destroy
  has_many :topic_names, :through => :topic_name_assignments

  has_many :topic_assignments, :dependent => :destroy
  has_many :topics, -> { order('topics.name') }, :through => :topic_assignments

  has_many :url_references, :dependent => :destroy
  has_many :urls, :through => :url_references

  has_many :place_determinations,
           -> { where("place_determinations.confidence >= #{PlaceDetermination::MIN_CONFIDENCE} OR place_determinations.relevance_score >= #{PlaceDetermination::MIN_RELEVANCE_SCORE}") },
           :dependent => :destroy
  has_many :places, :through => :place_determinations

  has_many :citations,
           :foreign_key => :source_entry_id,
           :dependent => :destroy
  has_many :cited_entries,
           :class_name => 'Entry',
           :through => :citations,
           :source => :cited_entry

  has_many :references, :class_name => 'Citation',
           :foreign_key => :cited_entry_id,
           :dependent => :nullify
  has_many :referencing_entries,
           :class_name => 'Entry',
           :through => :references,
           :source => :source_entry

  has_many :graphic_usages
  has_many :graphics,
           :through => :graphic_usages
  has_many :extracted_graphics,
           -> { where("graphics.graphic_file_name IS NOT NULL") },
           :through => :graphic_usages,
           :source => :graphic,
           :class_name => "Graphic"

  has_many :gpo_graphic_usages,
    :foreign_key => :document_number,
    :primary_key => :document_number
  has_many :gpo_graphics,
           :through => :gpo_graphic_usages
  has_many :image_usages,
           :foreign_key => :document_number,
           :primary_key => :document_number
  has_many :images,
           :through => :image_usages

  acts_as_mappable :through => :places

  has_many :docket_numbers, -> { order("docket_numbers.position") }, :as => :assignable, :dependent => :destroy

  has_many :agency_name_assignments, -> { order("agency_name_assignments.position") }, :as => :assignable, :dependent => :destroy
  has_many :agency_names, :through => :agency_name_assignments
  has_many :agencies, :through => :agency_names, :extend => Agency::AssociationExtensions

  has_many :events, :dependent => :destroy
  has_one :comments_close_date, -> { where(:event_type => 'CommentsClose') }, :class_name => "Event", :autosave => true
  has_one :effective_date, -> { where(event_type: 'EffectiveDate') }, :class_name => "Event", :autosave => true
  has_one :regulations_dot_gov_comments_close_date, -> { where(event_type: 'RegulationsDotGovCommentsClose') }, :class_name => "Event", :autosave => true

  before_save :set_document_file_path
  before_save :record_entry_change
  before_destroy :record_entry_change_on_destroy

  has_many :section_assignments
  has_many :sections, :through => :section_assignments

  has_many :section_highlights, dependent: :destroy
  belongs_to :lede_photo

  has_many :entry_page_views
  has_many :entry_emails

  has_many :events, :dependent => :destroy

  accepts_nested_attributes_for :lede_photo, :reject_if => Proc.new{|attr| attr["url"].blank? }

  file_attribute(:full_xml)  {"#{documents_path}/full_text/xml/#{document_file_path}.xml"}
  file_attribute(:full_text) {"#{documents_path}/full_text/text/#{document_file_path}.txt"}
  file_attribute(:raw_text)  {"#{documents_path}/full_text/raw/#{document_file_path}.txt"}

  has_many :entry_regulation_id_numbers
  has_many :regulatory_plans, :through => :entry_regulation_id_numbers
  has_many :current_regulatory_plans, -> {where(current: true)}, class_name: "RegulatoryPlan", :through => :entry_regulation_id_numbers
  has_many :entry_cfr_references, :dependent => :delete_all
  has_many :entry_cfr_affected_parts, -> { where("entry_cfr_references.part IS NOT NULL") }, :class_name => "EntryCfrReference"

  include Shared::DoesDocumentNumberNormalization

  validate :curated_attributes_are_not_too_long

  scope :pre_joined_for_es_indexing, -> { includes(
    :agencies,
    :agency_names,
    :agency_name_assignments,
    :citations,
    :comments_close_date,
    :corrections,
    :current_regulatory_plans,
    :docket_numbers,
    :effective_date,
    :entry_cfr_references,
    :extracted_graphics,
    :place_determinations,
    :public_inspection_document,
    :section_assignments,
    :topic_assignments,
    :topics,
    agency_names: [:agency],
    agency_name_assignments: [:agency_name],
    regs_dot_gov_docket: [:regs_dot_gov_supporting_documents],
    entry_regulation_id_numbers: [:current_regulatory_plan],
    gpo_graphics: [:gpo_graphic_usages],
    regs_dot_gov_documents: [:regs_dot_gov_docket],
    images: [:image_usages, :image_variants]
  ) }

  def self.published_today
    Issue.current.entries
  end

  def self.with_lede_photo
    scoped(:joins => :lede_photo)
  end

  def self.published_in(date_range)
    scoped(:conditions => {:entries => {:publication_date => date_range}})
  end

  def self.published_on(publication_date)
    scoped(:conditions => {:entries => {:publication_date => publication_date}})
  end

  def self.published_since(time)
    scoped(:conditions => {:entries => {:publication_date => time .. Time.now}})
  end

  def self.comments_closing(range = (Time.current.to_date .. Time.current.to_date + 127.days))
    scoped(
      :joins => :comments_close_date,
      :conditions => {:events => {:date => range}},
      :order => "events.date"
    )
  end

  def self.comments_opening(range = (Time.current.to_date - 7.days .. Time.current.to_date))
    scoped(
      :joins => :comments_close_date,
      :conditions => {:entries => {:publication_date => range}},
      :order => "events.date"
    )
  end

  def self.most_recent(n = 10)
    scoped(:order => "publication_date DESC", :limit => n)
  end

  def self.popular(since = 1.week.ago)
    scoped(
      :select => "entries.id, entries.title, entries.document_number, entries.publication_date, entries.abstract, count(distinct(remote_ip)) AS num_views",
      :joins => :entry_page_views,
      :conditions => ["entry_page_views.created_at > ?", since],
      :group => "entries.id",
      :having => "num_views > 0",
      :order => "num_views DESC"
    )
  end

  def self.most_emailed(since = 1.week.ago)
    scoped(
      :select => "entries.id, entries.title, entries.document_number, entries.publication_date, entries.abstract, count(distinct(remote_ip)) AS num_emails",
      :joins => :entry_emails,
      :conditions => ["entry_emails.created_at > ?", since],
      :group => "entries.id",
      :having => "num_emails > 0",
      :order => "num_emails DESC"
    )
  end

  def self.highlighted(date = IssueApproval.latest_publication_date)
    scoped(:joins => :section_highlights, :conditions => {:section_highlights => {:publication_date => date}})
  end

  def self.most_recent(n)
    scoped(:order => "entries.publication_date DESC", :limit => n.to_i)
  end

  def self.most_cited(n)
    scoped(:conditions => "entries.citing_entries_count > 0",
           :order => "citing_entries_count DESC, publication_date DESC",
           :limit => n.to_i)
  end

  def self.of_type(type)
    scoped(:conditions => {:granule_class => type})
  end

  def self.with_regulation_id_number(rin)
    scoped(:conditions => {:entry_regulation_id_numbers => {:regulation_id_number => rin}}, :joins => :entry_regulation_id_numbers)
  end

  def self.executive_order
    scoped(:conditions => {:presidential_document_type_id => PresidentialDocumentType::EXECUTIVE_ORDER})
  end

  def self.delta_index_names
    ['entry_delta']
  end

  def self.core_index_names
    ['entry_core']
  end

  def self.search_klass
    EsEntrySearch
  end

  def self.default_repository
    $extended_timeout_entry_repository
  end

  def self.always_render_document_number_search_results_via_active_record?
    false
  end

  def excerpt
    return @excerpt if @excerpt

    if abstract.present?
      truncate_words(abstract, length: 255)
    else
      nil
    end
  end

  def processed_gpo_graphics
    gpo_graphics.select{|g| g.graphic_file_name.present?}
  end

  def graphic_identifiers
    if graphics.extracted.present?
      graphics.extracted.map(&:identifier)
    elsif processed_gpo_graphics.present?
      processed_gpo_graphics.map(&:identifier)
    else
      []
    end
  end

  def granule_class
    self[:granule_class] || 'UNKNOWN'
  end

  def entry_type
    ENTRY_TYPES[granule_class]
  end

  alias_method :category, :entry_type

  # define_index do
  #   set_property "sql_query_killlist", <<-SQL.gsub(/\s+/, ' ')
  #     SELECT entries.id #{ThinkingSphinx.unique_id_expression(ThinkingSphinx::MysqlAdapter.new(Entry), Entry.sphinx_offset) }
  #     FROM entries
  #     WHERE delta = 1
  #   SQL

  #   # fields
  #   indexes title
  #   indexes abstract
  #   indexes "CONCAT('#{FileSystemPathManager.data_file_path}/documents/full_text/raw/', document_file_path, '.txt')", :as => :full_text, :file => true
  #   indexes "GROUP_CONCAT(DISTINCT IFNULL(`entry_regulation_id_numbers`.`regulation_id_number`, '0') SEPARATOR ' ')", :as =>  :regulation_id_number
  #   indexes <<-SQL, :as => :docket_id
  #     (
  #       SELECT GROUP_CONCAT(DISTINCT docket_numbers.number SEPARATOR ' ')
  #       FROM docket_numbers
  #       WHERE docket_numbers.assignable_id = entries.id
  #         AND docket_numbers.assignable_type = 'Entry'
  #     )
  #   SQL

  #   has "CRC32(document_number)", :as => :document_number, :type => :integer
  #   has "CRC32(IF(granule_class = 'SUNSHINE', 'NOTICE', granule_class))", :as => :type, :type => :integer
  #   has presidential_document_type_id

  #   has publication_date
  #   has "IF(granule_class = 'PRESDOCU', IFNULL(signing_date, publication_date), NULL)", as: :signing_date, type: :datetime

  #   has "IF(granule_class = 'PRESDOCU', INTERVAL(DATE_FORMAT(IFNULL(signing_date,DATE_SUB(publication_date, INTERVAL 3 DAY)), '%Y%m%d'),#{President.all.map{|p| p.starts_on.strftime("%Y%m%d")}.join(', ')}), NULL)", :as => :president_id, :type => :integer
  #   has "IF(granule_class = 'CORRECT' OR correction_of_id IS NOT NULL OR (presidential_document_type_id = 2 AND (executive_order_number = 0 or executive_order_number IS NULL)), 1, 0)", :as => :correction, :type => :boolean
  #   has start_page
  #   has executive_order_number
  #   has proclamation_number

  #   has <<-SQL, :as => :cfr_affected_parts, :type => :multi
  #     (
  #       SELECT GROUP_CONCAT(DISTINCT title * #{EntrySearch::CFR::TITLE_MULTIPLIER} + part SEPARATOR ',')
  #       FROM entry_cfr_references
  #       WHERE entry_id = entries.id
  #     )
  #   SQL
  #   has <<-SQL, :as => :agency_ids, :type => :multi
  #     (
  #       SELECT GROUP_CONCAT(DISTINCT agency_id SEPARATOR ',')
  #       FROM agency_assignments
  #       WHERE assignable_id = entries.id
  #         AND assignable_type = 'Entry'
  #         AND agency_id IS NOT NULL
  #     )
  #   SQL
  #   has <<-SQL, :as => :topic_ids, :type => :multi
  #     (
  #       SELECT GROUP_CONCAT(DISTINCT topic_id SEPARATOR ',')
  #       FROM topic_assignments
  #       WHERE entry_id = entries.id
  #         AND topic_id IS NOT NULL
  #     )
  #   SQL
  #   has <<-SQL, :as => :section_ids, :type => :multi
  #     (
  #       SELECT GROUP_CONCAT(DISTINCT section_id SEPARATOR ',')
  #       FROM section_assignments
  #       WHERE entry_id = entries.id
  #         AND section_id IS NOT NULL
  #     )
  #   SQL
  #   has <<-SQL, :as => :place_ids, :type => :multi
  #     (
  #       SELECT GROUP_CONCAT(DISTINCT IFNULL(place_id, '0') SEPARATOR ',')
  #       FROM place_determinations
  #       WHERE entry_id = entries.id
  #         AND place_id IS NOT NULL
  #     )
  #   SQL
  #   has <<-SQL, :as => :cited_entry_ids, :type => :multi
  #     (
  #       SELECT GROUP_CONCAT(DISTINCT cited_entry_id SEPARATOR ',')
  #       FROM citations
  #       WHERE source_entry_id = entries.id
  #         AND cited_entry_id IS NOT NULL
  #     )
  #   SQL
  #   has effective_date(:date), :as => :effective_date
  #   has comments_close_date(:date), :as => :comment_date

  #   has "IF(comment_url != '', 1, 0)", :as => :accepting_comments_on_regulations_dot_gov, :type => :boolean

  #   join small_entities_for_thinking_sphinx
  #   has "GROUP_CONCAT(DISTINCT IFNULL(regulatory_plans_small_entities.small_entity_id,0) SEPARATOR ',')", :as => :small_entity_ids, :type => :multi
  #   has "SUM(IF(regulatory_plans.priority_category IN (#{RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES.map{|c| "'#{c}'"}.join(',')}),1,0)) > 0",
  #     :as => :significant,
  #     :type => :boolean

  #   set_property :field_weights => {
  #     "title" => 100,
  #     "abstract" => 50,
  #     "full_text" => 25,
  #     "agency_name" => 10
  #   }

  #   set_property :delta => ThinkingSphinx::Deltas::ManualDelta
  # end
  # # this line must appear after the define_index block
  # include ThinkingSphinx::Deltas::ManualDelta::ActiveRecord

  def title
    if self[:title].present? && self[:title] =~ /[A-Za-z]/
      self[:title]
    else
      '[No title available]'
    end
  end

  def toc_doc
    if self[:toc_doc].present?
      self[:toc_doc].sub(/\s*,\s*$/,'')
    else
      nil
    end
  end

  def curated_title
    self[:curated_title].present? ? self[:curated_title] : title
  end

  def curated_abstract
    self[:curated_abstract].present? ? self[:curated_abstract] : abstract
  end

  def day
    publication_date.strftime('%d')
  end

  def active
    response_code == '200' ? true : false
  end

  def slug
    clean_title = title.downcase.gsub(/[^a-z0-9& -]+/,'').gsub(/&/, 'and')
    slug = view_helper.truncate_words(clean_title, :length => 100, :omission => '')
    slug.gsub(/ /,'-')
  end

  def clear_varnish!
    paths = [
      "^/api/v1/documents/#{document_number}",
      "^/documents/#{publication_date.to_s(:ymd)}/#{document_number}"
    ]
    if presidential_document?
      paths << "^/presidential-documents"
      paths << "^/esi/layouts/navigation/presidential-documents"
      paths << "^/esi/home/presidential_documents"
    end

    paths.each {|path| purge_cache(path) }
  end


  def comments_close_on
    comments_close_date.try(:date)
  end

  def comments_open?
    comments_close_on.present? && comments_close_on >= Date.today
  end

  def effective_on
    effective_date.try(:date)
  end

  def regulations_dot_gov_comments_close_on
    regulations_dot_gov_comments_close_date.try(:date)
  end

  def regulations_dot_gov_comments_close_on=(date)
    if date
      event = regulations_dot_gov_comments_close_date || events.build(:event_type => 'RegulationsDotGovCommentsClose')
      event.date = date
    else
      regulations_dot_gov_comments_close_date.try(:delete)
    end
  end

  def source_url(format)
    case format.to_sym
    when :mods
      "https://www.govinfo.gov/metadata/granule/FR-#{publication_date.to_s(:iso)}/#{document_number}/mods.xml"
    when :html
      "https://www.govinfo.gov/app/details/FR-#{publication_date.to_s(:db)}/#{document_number}"
    when :text
      "https://www.govinfo.gov/content/pkg/FR-#{publication_date.to_s(:db)}/html/#{document_number}.htm"
    when :pdf
      if publication_date >= GPO_PDF_START_DATE
        "https://www.govinfo.gov/content/pkg/FR-#{publication_date.to_s(:iso)}/pdf/#{document_number}.pdf"
      end
    end
  end

  def entries_within(distance, options={})
    limit = options.delete(:limit) || 10
    count = options.delete(:count) || false

    if count
      entry_count = 0
      places.each do |place|
        entry_count = entry_count + Entry.count_within(distance, :origin => place.location)
      end
      entry_count
    else
      entries = []
      places.each do |place|
        entries += Entry.find_within(distance, :origin => place.location, :limit => limit, :order => 'distance')
      end
      entries.uniq.sort_by{|e| e.publication_date}[0..9].flatten
    end
  end

  def self.find_near(loc, dist = 100)
    places  = Place.find_places_near(loc, dist)
    entries = []
    places.each do |place|
      entries << place.entry
    end
    entries
  end

  def self.earliest_publication_date
    with_exclusive_scope do
      Entry.find(:first, :select => "publication_date", :order => "publication_date").publication_date
    end
  end

  def self.latest_publication_dates(n)
    select("publication_date").
    where("publication_date <= ?", Issue.current.publication_date).
    order("publication_date DESC").
    group("publication_date").
    limit(n).
    map(&:publication_date)
  end

  def self.find_all_by_citation(volume, page)
    scoped(:conditions => ["volume = ? AND start_page <= ? AND end_page >= ?", volume.to_i, page.to_i, page.to_i], :order => "entries.end_page", :limit => 100)
  end

  def self.find_all_by_starting_citation(volume, page)
    scoped(:conditions => ["volume = ? AND start_page = ?", volume.to_i, page.to_i], :order => "entries.start_page", :limit => 100)
  end

  def self.find_best_citation_matches(volume, page, agencies = [])
    candidates = find_all_by_citation(volume, page)

    if candidates.empty?
      candidates = find_all_by_citation(volume,page)
    end

    agency_ids = agencies.map(&:id)
    if candidates.present? && agency_ids.present?
      agency_candidates = candidates.reject{|x| (x.agency_ids & agency_ids).empty? }
    end

    if agency_candidates.present?
      agency_candidates
    else
      candidates
    end
  end


  def self.first_publication_date_before(date)
    Entry.find(:first,
        :select => 'publication_date',
        :conditions => ["publication_date < ?", date],
        :order => 'publication_date DESC'
    ).try(:publication_date)
  end

  def self.first_publication_date_after(date)
    Entry.find(:first,
        :select => 'publication_date',
        :conditions => ["publication_date > ?", date],
        :order => 'publication_date'
    ).try(:publication_date)
  end

  # TODO: remove this method when no longer called
  def agency
    ActiveSupport::Deprecation.warn("Entry#agency is deprecated. Entries are now associated with multiple agencies.")
    agencies.first
  end

  def executive_order_number
    if presidential_document_type == PresidentialDocumentType::EXECUTIVE_ORDER
      presidential_document_number
    end
  end

  def has_type?
    entry_type != 'Unknown'
  end

  def lede_photo_candidates
    self[:lede_photo_candidates] ? YAML::load(self[:lede_photo_candidates]) : []
  end

  def proclamation_number
    if presidential_document_type == PresidentialDocumentType::PROCLAMATION
      presidential_document_number
    end
  end

  def regulation_id_numbers=(rins)
    @regulation_id_numbers = rins
    self.entry_regulation_id_numbers = rins.map do |rin|
      entry_regulation_id_numbers.to_a.find{|erin| erin.regulation_id_number == rin} || EntryRegulationIdNumber.new(:regulation_id_number => rin)
    end
    rins
  end

  def regulation_id_numbers
    @rins || self.entry_regulation_id_numbers.map(&:regulation_id_number)
  end

  def significant?
    current_regulatory_plans.any?(&:significant?)
  end

  def executive_order?
    (presidential_document_type == PresidentialDocumentType::EXECUTIVE_ORDER) &&
    presidential_document_number.present?
  end

  def presidential_document?
    presidential_document_type_id.present?
  end

  def previous_entry
    @previous_entry ||= Entry.
      where("entries.volume <= ? AND entries.start_page <= ? AND entries.id < ?", volume, start_page, id).
      order("entries.volume DESC, entries.start_page DESC, entries.id DESC").
      first
  end

  def next_entry
    @next_entry ||= Entry.
      where("entries.volume >= ? AND entries.start_page >= ? AND entries.id > ?", volume, start_page, id).
      order("entries.volume, entries.start_page, entries.id").
      first
  end

  def should_have_full_xml?
    full_xml_updated_at.present?
  end

  def republication?
    document_number =~ /^R/
  end

  def president
    date = signing_date || (publication_date - 3)
    President.in_office_on(date)
  end

  def regulations_dot_gov_agency_id
    regulations_dot_gov_document_id.present? ? regulations_dot_gov_document_id.split((/[-_]/)).first : nil
  end

  def regulations_dot_gov_url
    calculated_comment_url.present? ? calculated_comment_url.gsub('#!submitComment', '#!documentDetail') : nil
  end

  def calculated_comment_url
    comment_url_override.present? ? comment_url_override : comment_url
  end

  def documents_path
    "#{FileSystemPathManager.data_file_path}/documents"
  end

  def document_file_path
    "#{publication_date.to_s(:ymd)}/#{document_number}"
  end

  def to_hash
    EntrySerializer.new(self).to_h
  end

  private

  def record_entry_change_on_destroy
    if entry_change.nil?
      EntryChange.create!(entry_id: id)
    end
  end

  def record_entry_change
    if entry_change.nil? && new_or_changed?
      build_entry_change
    end
  end

  def new_or_changed?
    new_record? || changed?
  end

  def set_document_file_path
    if document_number.present? && publication_date.present?
      self.document_file_path = "#{publication_date.to_s(:ymd)}/#{document_number}"
    end

    true
  end

  def curated_attributes_are_not_too_long
    if self[:curated_title].present? && self[:curated_title].size > 255
      errors.add(:curated_title, "exceeds 255 characters")
    end

    if self[:curated_abstract].present? && self[:curated_abstract].size > 500
      errors.add(:curated_abstract, "exceeds 500 characters")
    end
  end

end

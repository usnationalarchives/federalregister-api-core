class PublicInspectionDocument < ApplicationModel

  has_attached_file :pdf,
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.secrets[:aws][:access_key_id],
                      :secret_access_key => Rails.application.secrets[:aws][:secret_access_key],
                      :s3_region => 'us-east-1'
                    },
                    :s3_host_alias => Settings.app.aws.s3.host_aliases.public_inspection,
                    :s3_protocol => 'https',
                    :bucket => Settings.app.aws.s3.buckets.public_inspection,
                    :path => ":style_if_not_with_banner:document_number.pdf",
                    :default_style => :with_banner,
                    :styles => {
                      :with_banner => { :processors => [:permalink_banner_adder] }
                    },
                    :processors => [:permalink_banner_adder],
                    :default_url => "missing.pdf",
                    :url => ':s3_alias_url'
  do_not_validate_attachment_file_type :pdf

  belongs_to :entry
  has_and_belongs_to_many :public_inspection_issues,
                          :join_table              => :public_inspection_postings,
                          :foreign_key             => :document_id,
                          :association_foreign_key => :issue_id
  has_many :agency_name_assignments, -> { order("agency_name_assignments.position") }, :as => :assignable, :dependent => :destroy
  has_many :agency_names, :through => :agency_name_assignments
  has_many :agencies, :through => :agency_names, :extend => Agency::AssociationExtensions
  has_many :docket_numbers, -> { order("docket_numbers.position") }, :as => :assignable, :dependent => :destroy
  has_many :pil_agency_letters, :dependent => :destroy

  file_attribute(:raw_text)  {"#{FileSystemPathManager.data_file_path}/public_inspection/raw/#{document_file_path}.txt"}
  before_save :persist_document_file_path
  before_save :set_content_type

  scope :revoked, -> { where(publication_date: nil) }
  scope :pre_joined_for_es_indexing, -> { includes(:docket_numbers) }

  include Shared::DoesDocumentNumberNormalization

  # Note: the concept of 'unpublished' is different from that of 'pending publication'
  def self.unpublished
    scoped(:conditions => ["publication_date > ?", Issue.current.try(:publication_date)])
  end

  def self.special_filing
    scoped(:conditions => {:special_filing => true})
  end

  def self.regular_filing
    scoped(:conditions => {:special_filing => false})
  end

  def self.search_klass
    EsPublicInspectionDocumentSearch
  end

  def self.default_repository
    $public_inspection_document_repository
  end

  def self.always_render_document_number_search_results_via_active_record?
    true
  end

  def self.indexable
    base_scope = PublicInspectionDocument.
      joins("INNER JOIN public_inspection_postings ON public_inspection_documents.id = public_inspection_postings.document_id")

    if Settings.app.public_inspection_documents.index_since_date
      index_since_date = Date.parse(Settings.app.public_inspection_documents.index_since_date)

      base_scope.
        where(<<-SQL
          public_inspection_postings.issue_id =
            (
              SELECT id
              FROM public_inspection_issues
              WHERE published_at >= #{index_since_date}
              ORDER BY publication_date DESC
              LIMIT 1
            )
          AND (
            publication_date IS NULL
            OR publication_date > #{index_since_date}
          )
        SQL
      )
    else
      base_scope.
        where(<<-SQL
          public_inspection_postings.issue_id =
            (
              SELECT id
              FROM public_inspection_issues
              WHERE published_at IS NOT NULL
              ORDER BY publication_date DESC
              LIMIT 1
            )
          AND (
            public_inspection_documents.publication_date IS NULL
            OR public_inspection_documents.publication_date > (
              SELECT MAX(publication_date)
              FROM issues
              WHERE issues.completed_at IS NOT NULL
            )
          )
        SQL
      )
    end
  end

  def entry
    @entry ||= Entry.find_by_document_number(document_number)
  end

  def entry_type
    Entry::ENTRY_TYPES[granule_class]
  end

  attr_writer :excerpt
  def excerpt
    return @excerpt if @excerpt

    # nothing to display if excerpt hasn't been set elsewhere
    nil
  end

  def document_file_path
    read_attribute(:document_file_path) || document_number.sub(/-/,'').scan(/.{0,3}/).reject(&:blank?).join('/')
  end

  def slug
    clean_title = title.downcase.gsub(/[^a-z0-9& -]+/,'').gsub(/&/, 'and')
    slug = view_helper.truncate_words(clean_title, :length => 100, :omission => '')
    slug.gsub(/ /,'-')
  end

  # FIXME: these are only defined so that the presenter doesn't blow up...
  #   the presenter should be made more dynamic and handle different sort orders.
  def start_page
    0
  end

  def end_page
    0
  end

  def category
    self['category'] || entry_type
  end

  def title
    [subject_1, subject_2, subject_3].reject(&:blank?).join(' ')
  end

  def toc_subject
    if subject_3.present?
      [subject_1, subject_2].join(' ')
    elsif subject_2.present?
      subject_1
    else
      ''
    end
  end

  def toc_doc
    [subject_3,subject_2,subject_1].reject(&:blank?).first || ''
  end

  def pdf_displayable?
    pdf_file_name.present? &&
    (
      publication_date.present? ||
      Time.current < Time.zone.parse("#{public_inspection_issues.order("publication_date DESC").first.publication_date.to_s(:db)} 5:15PM")
    )
  end


  def to_hash
    PublicInspectionDocumentSerializer.new(self).to_h
  end

  private

  def persist_document_file_path
    self.document_file_path = document_file_path
  end

  def set_content_type
    self.pdf.instance_write(:content_type,'application/pdf') if self.pdf.present?
  end

end

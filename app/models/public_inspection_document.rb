class PublicInspectionDocument < ApplicationModel
  has_attached_file :pdf,
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => SECRETS['aws']['access_key_id'],
                      :secret_access_key => SECRETS['aws']['secret_access_key']
                    },
                    :s3_protocol => 'https',
                    :bucket => "public-inspection.#{APP_HOST_NAME}",
                    :path => ":style_if_not_with_banner:document_number.pdf",
                    :default_style => :with_banner,
                    :styles => {
                      :with_banner => { :processors => [:permalink_banner_adder] }
                    },
                    :processors => [:permalink_banner_adder],
                    :default_url => "missing.pdf"

  belongs_to :entry
  has_and_belongs_to_many :public_inspection_issues,
                          :join_table              => :public_inspection_postings,
                          :foreign_key             => :document_id,
                          :association_foreign_key => :issue_id
  has_many :agency_name_assignments, :as => :assignable, :order => "agency_name_assignments.position", :dependent => :destroy
  has_many :agency_names, :through => :agency_name_assignments
  has_many :agency_assignments, :as => :assignable, :order => "agency_assignments.position", :dependent => :destroy
  has_many :agencies, :through => :agency_assignments, :order => "agency_assignments.position", :extend => Agency::AssociationExtensions
  has_many :docket_numbers, :as => :assignable, :order => "docket_numbers.position", :dependent => :destroy

  file_attribute(:raw_text)  {"#{RAILS_ROOT}/data/public_inspection/raw/#{document_file_path}.txt"}
  before_save :persist_document_file_path
  before_save :set_content_type

  named_scope :revoked, :conditions => {:publication_date => nil}
  does 'shared/document_number_normalization'

  define_index do
    # fields
    indexes <<-SQL, :as => :title
      CONCAT(
        IFNULL(public_inspection_documents.subject_1, ''),
        ' ',
        IFNULL(public_inspection_documents.subject_2, ''),
        ' ',
        IFNULL(public_inspection_documents.subject_3, '')
      )
    SQL
    indexes "CONCAT('#{RAILS_ROOT}/data/public_inspection/raw/', public_inspection_documents.document_file_path, '.txt')", :as => :full_text, :file => true
    indexes "GROUP_CONCAT(DISTINCT docket_numbers.number SEPARATOR ' ')", :as => :docket_id

    # attributes
    has "CRC32(document_number)", :as => :document_number, :type => :integer
    has "public_inspection_documents.id", :as => :public_inspection_document_id, :type => :integer
    has "CRC32(IF(public_inspection_documents.granule_class = 'SUNSHINE', 'NOTICE', public_inspection_documents.granule_class))", :as => :type, :type => :integer
    has agency_assignments(:agency_id), :as => :agency_ids
    has publication_date
    has filed_at
    has special_filing

    join docket_numbers

    set_property :field_weights => {
      "title" => 100,
      "full_text" => 25,
      "agency_name" => 10
    }

    where "public_inspection_documents.publication_date > (SELECT MAX(publication_date) FROM issues where issues.completed_at is not null)"
  end

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

  def entry
    @entry ||= Entry.find_by_document_number(document_number)
  end

  def entry_type
    Entry::ENTRY_TYPES[granule_class]
  end

  def document_file_path
    self['document_file_path'] || document_number.sub(/-/,'').scan(/.{0,3}/).reject(&:blank?).join('/')
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
      nil
    end
  end

  def toc_doc
    [subject_3,subject_2,subject_1].reject(&:blank?).first
  end

  def pdf_displayable?
    pdf_file_name.present? &&
    (
      publication_date.present? ||
      Time.current < Time.zone.parse("#{public_inspection_issues.first(:order => "publication_date DESC").publication_date.to_s(:db)} 5:15PM")
    )
  end

  def make_s3_files_private!
    pdf.styles.each_pair do |style, options|
      path = pdf.path(style)
      bucket = pdf.bucket_name
      obj = AWS::S3::S3Object.find(path, bucket)

      grantee = AWS::S3::ACL::Grantee.new
      grantee.id = obj.owner.id
      grantee.type = 'CanonicalUser'

      grant = AWS::S3::ACL::Grant.new
      grant.permission = 'FULL_CONTROL'
      grant.grantee = grantee

      obj.acl.grants = [grant]
      obj.acl(obj.acl)
    end
    touch(:updated_at)
  end

  private

  def persist_document_file_path
    self.document_file_path = document_file_path
  end

  def set_content_type
    self.pdf.instance_write(:content_type,'application/pdf') if self.pdf.present?
  end
end

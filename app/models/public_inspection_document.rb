# == Schema Information
#
# Table name: public_inspection_documents
#
#  id                  :integer(4)      not null, primary key
#  document_number     :string(255)
#  granule_class       :string(255)
#  filed_at            :datetime
#  publication_date    :date
#  toc_subject         :string(255)
#  toc_doc             :string(255)
#  special_filing      :boolean(1)      not null
#  pdf_file_name       :string(255)
#  pdf_file_size       :integer(4)
#  pdf_updated_at      :datetime
#  pdf_etag            :string(255)
#  title               :string(255)     default(""), not null
#  editorial_note      :text
#  document_file_path  :string(255)
#  raw_text_updated_at :datetime
#  delta               :boolean(1)      default(TRUE), not null
#  num_pages           :integer(4)
#

class PublicInspectionDocument < ApplicationModel
  has_attached_file :pdf,
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/amazon.yml",
                    :s3_alias_url => 'http://public-inspection.federalregister.gov.s3.amazonaws.com/',
                    :bucket => 'public-inspection.federalregister.gov',
                    :path => ":document_number.pdf"

  has_one :entry,
          :foreign_key => :document_number,
          :primary_key => :document_number
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

  define_index do
    # fields
    indexes "IF(public_inspection_documents.title = '', CONCAT(public_inspection_documents.toc_subject, ' ', public_inspection_documents.toc_doc), public_inspection_documents.title)", :as => :title
    indexes "LOAD_FILE(CONCAT('#{RAILS_ROOT}/data/public_inspection/raw/', public_inspection_documents.document_file_path, '.txt'))", :as => :full_text
    indexes "GROUP_CONCAT(DISTINCT docket_numbers.number SEPARATOR ' ')", :as => :docket_id
    
    # attributes
    has "public_inspection_documents.id", :as => :public_inspection_document_id, :type => :integer
    has "CRC32(IF(public_inspection_documents.granule_class = 'SUNSHINE', 'NOTICE', public_inspection_documents.granule_class))", :as => :type, :type => :integer
    has agency_assignments(:agency_id), :as => :agency_ids
    has publication_date
    has filed_at

    join docket_numbers
    join entry

    set_property :field_weights => {
      "title" => 100,
      "full_text" => 25,
      "agency_name" => 10
    }
    
    where "public_inspection_documents.publication_date && entries.id IS NULL"
  end

  # Note: the concept of 'unpublished' is different from that of 'pending publication'
  def self.unpublished
    scoped(:include => :entry, :conditions => "entries.id IS NULL")
  end

  def self.special_filing
    scoped(:conditions => {:special_filing => true})
  end

  def self.regular_filing
    scoped(:conditions => {:special_filing => false})
  end

  def entry_type 
    Entry::ENTRY_TYPES[granule_class]
  end

  def document_file_path
    self['document_file_path'] || document_number.sub(/-/,'').scan(/.{0,3}/).reject(&:blank?).join('/')
  end

  def slug
    base = title.present? ? title : [toc_doc, toc_subject].join(' ')
    clean_title = base.downcase.gsub(/[^a-z0-9& -]+/,'').gsub(/&/, 'and')
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

  private

  def persist_document_file_path
    self.document_file_path = document_file_path
  end

  def set_content_type
    self.pdf.instance_write(:content_type,'application/pdf') if self.pdf.present?
  end
end

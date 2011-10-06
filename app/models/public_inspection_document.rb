class PublicInspectionDocument < ApplicationModel
  has_attached_file :pdf,
                    :storage => :s3,
                    :s3_headers => { 'Content-Type' => 'application/pdf' },
                    :s3_credentials => "#{Rails.root}/config/amazon.yml",
                    :s3_alias_url => 'http://public-inspection.federalregister.gov.s3.amazonaws.com/',
                    :bucket => 'public-inspection.federalregister.gov',
                    :path => ":document_number.pdf"

  has_and_belongs_to_many :public_inspection_issues,
                          :join_table              => :public_inspection_postings,
                          :foreign_key             => :document_id,
                          :association_foreign_key => :issue_id
  has_many :agency_name_assignments, :as => :assignable, :order => "agency_name_assignments.position", :dependent => :destroy
  has_many :agency_names, :through => :agency_name_assignments
  has_many :agency_assignments, :as => :assignable, :order => "agency_assignments.position", :dependent => :destroy
  has_many :agencies, :through => :agency_assignments, :order => "agency_assignments.position", :extend => Agency::AssociationExtensions

  def self.special_filing
    scoped(:conditions => {:special_filing => true})
  end

  def self.regular_filing
    scoped(:conditions => {:special_filing => false})
  end

  def entry_type 
    Entry::ENTRY_TYPES[granule_class]
  end

  # FIXME: these are only defined so that the presenter doesn't blow up...
  #   the presenter should be made more dynamic and handle different sort orders.
  def start_page
    0
  end

  def end_page
    0
  end
end

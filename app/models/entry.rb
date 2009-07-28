=begin Schema Information

 Table name: entries

  id                   :integer(4)      not null, primary key
  title                :text
  abstract             :text
  contact              :text
  dates                :text
  action               :text
  type                 :string(255)
  link                 :string(255)
  genre                :string(255)
  part_name            :string(255)
  citation             :string(255)
  granule_class        :string(255)
  document_number      :string(255)
  toc_subject          :string(255)
  toc_doc              :string(255)
  length               :integer(4)
  start_page           :integer(4)
  end_page             :integer(4)
  agency_id            :integer(4)
  publication_date     :date
  effective_date       :date
  places_determined_at :datetime
  created_at           :datetime
  updated_at           :datetime

=end Schema Information

class Entry < ActiveRecord::Base
  
  DESCRIPTIONS = {
    :notice => 'This section of the Federal Register contains documents other than rules 
                or proposed rules that are applicable to the public. Notices of hearings 
                and investigations, committee meetings, agency decisions and rulings, 
                delegations of authority, filing of petitions and applications and agency 
                statements of organization and functions are examples of documents 
                appearing in this section.'
  }
  
  belongs_to :agency
  
  has_many :topic_assignments
  has_many :topics, :through => :topic_assignments
  
  has_many :url_references
  has_many :urls, :through => :url_references
  
  has_many :place_determinations
  has_many :places, :through => :place_determinations
  
  has_many :referenced_dates, :dependent => :destroy
  
  before_save :slugify
  
  # def to_param
  #   "#{document_number}"
  # end
  
  def month_year
    publication_date.to_formatted_s(:month_year)
  end
  
  def day
    publication_date.strftime('%d')
  end

  def active
    response_code == '200' ? true : false
  end
  
  def human_length
    if length.blank? 
      page_length = end_page - start_page == 0 ? 1 : end_page - start_page
    else
      page_length = length
    end
  end
  
  #private
  
  def slugify
    unless self.title.nil?
      self.slug = "#{self.title.downcase.gsub(/&/, 'and').gsub(/[^a-z0-9]+/, '-')}"
    end
  end
end

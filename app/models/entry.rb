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
  places_determined_at :datetime
  created_at           :datetime
  updated_at           :datetime
  slug                 :text
  full_text            :text
  full_text_raw        :text

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
  
  acts_as_mappable :through => :places
  
  has_many :referenced_dates, :dependent => :destroy
  
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
  
  def slug
    "#{self.title.downcase.gsub(/&/, 'and').gsub(/[^a-z0-9]+/, '-')}"
  end
  
  def effective_date
    referenced_dates.find(:first, :conditions => {:date_type => 'EffectiveDate'}).try(:date)
  end
  
  def source_url(format)
    format = format.to_sym
    
    case format
    when :html
      base_url = "http://www.gpo.gov/fdsys/granule/FR-#{publication_date}/#{document_number}"
    when :text
      base_url = "http://www.gpo.gov/fdsys/pkg/FR-#{publication_date}/html/#{document_number}.htm"
    when :pdf
      base_url =  "http://www.gpo.gov/fdsys/pkg/FR-#{publication_date}/pdf/#{document_number}.pdf"
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
        entries << Entry.find_within(distance, :origin => place.location, :limit => limit, :order => 'distance')
      end
      entries.uniq.sort{|e| e.publication_date}[0..9].flatten
    end
  end
end

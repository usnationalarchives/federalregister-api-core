class CannedSearch < ApplicationModel
  does 'shared/slug', :based_on => :title

  belongs_to :section
  validates_presence_of :section, :title, :description, :search_conditions

  acts_as_list :scope => :section_id 
  named_scope :in_order, :order => "position"
  named_scope :inactive, :conditions => {:active => 0}
  
  def new_position=(new_pos)
    insert_at(new_pos)
  end

  attr_reader :search_url
  def search_url=(search_url)
    @search_url = search_url
    if search_url.present?
      search_parameters = search_url.sub(/.*\?/, '')
      self.search_conditions = Rack::Utils.parse_nested_query(search_parameters)['conditions'].to_json 
    end
    search_url
  end
  
  def search_conditions
    JSON.parse(self['search_conditions']||'{}')
  end

  def search
    @search ||= EntrySearch.new(:conditions => search_conditions, :order => "newest")
  end

  def documents_in_last(time_frame)
    conditions = search_conditions.merge(
      :publication_date => {
        :gte => Issue.current.publication_date - time_frame
      }
    )
    EntrySearch.new(:conditions => conditions, :metadata_only => true).count
  end
end

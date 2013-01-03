# == Schema Information
#
# Table name: canned_searches
#
#  id                :integer(4)      not null, primary key
#  section_id        :integer(4)
#  title             :string(255)
#  slug              :string(255)
#  description       :text(16777215)
#  search_conditions :text(16777215)
#  active            :boolean(1)
#  position          :integer(4)
#

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
end

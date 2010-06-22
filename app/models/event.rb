class Event < ApplicationModel
  EVENT_TYPES_SINGULAR = {
    'PublicMeeting' => 'Public Meeting',
    'ClosedMeeting' => 'Closed Meeting',
    'CommentsOpen'  => 'Comment Period Opening',
    'CommentsClose' => 'Comment Period Closing',
    'EffectiveDate' => 'Effective Date'
  }
  EVENT_TYPES_PLURAL = {
    'PublicMeeting' => 'Public Meetings',
    'ClosedMeeting' => 'Closed Meetings',
    'CommentsOpen'  => 'Comment Periods Opening',
    'CommentsClose' => 'Comment Periods Closing',
    'EffectiveDate' => 'Effective Dates'
  }
  
  belongs_to :entry
  belongs_to :place
  has_many :agency_assignments, :through => :entry, :foreign_key => "entries.id"
  validates_presence_of :entry, :date, :event_type
  validates_presence_of :title, :place, :if => Proc.new{|e| e.event_type == 'PublicMeeting' || e.event_type == 'ClosedMeeting'}
  validates_inclusion_of :event_type, :in => EVENT_TYPES_SINGULAR.keys
  
  def agencies
    agency_assignments.map(:agency)
  end
  
  def type
    Event::EVENT_TYPES_SINGULAR[event_type]
  end
  
  def title
    self['title'] || entry.title
  end
  
  define_index do
    # fields
    indexes "IFNULL(events.title, entries.title)", :as => :title
    indexes entry.abstract
    indexes place.name, :as => :place
    indexes event_type, :as => :type, :facet => true
    indexes "LOAD_FILE(CONCAT('#{RAILS_ROOT}/data/text/', entries.document_file_path, '.txt'))", :as => :entry_full_text
    
    # attributes
    has date
    has entry.agency_assignments(:agency_id), :as => :agency_ids
    has place_id
    
    set_property :field_weights => {
      "title" => 100,
      "place" => 50,
      "abstract" => 50,
      "full_text" => 25,
    }
  end
  
end
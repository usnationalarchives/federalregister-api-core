class Event < ApplicationModel
  belongs_to :entry
  belongs_to :place
  has_many :agency_assignments, :through => :entry, :foreign_key => "entries.id"
  validates_presence_of :entry, :place, :date, :title
  
  def agencies
    agency_assignments.map(:agency)
  end
  
  define_index do
    # fields
    indexes title
    indexes date
    indexes entry.abstract
    indexes place.name
    indexes "LOAD_FILE(CONCAT('#{RAILS_ROOT}/data/text/', entries.document_file_path, '.txt'))", :as => :entry_full_text
    
    # attributes
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
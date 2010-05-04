=begin Schema Information

 Table name: section_highlights

  id               :integer(4)      not null, primary key
  section_id       :integer(4)
  entry_id         :integer(4)
  position         :integer(4)
  publication_date :date

=end Schema Information

class SectionHighlight < ApplicationModel
  belongs_to :section
  belongs_to :entry
  
  validates_presence_of :section, :entry, :publication_date
  validates_uniqueness_of :entry_id, :scope => [:section_id, :publication_date]
  
  delegate :curated_title, :curated_title=, :curated_abstract, :curated_abstract=, :to => :entry
  
  acts_as_list :scope => 'section_id = #{section_id} AND publication_date = \'#{publication_date.to_s(:db)}\''
  
  before_save :update_entry
  
  def new_position=(new_pos)
    insert_at(new_pos)
  end
  
  private
  
  def update_entry
    entry.save
  end
end

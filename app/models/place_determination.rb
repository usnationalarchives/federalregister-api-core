=begin Schema Information

 Table name: place_determinations

  id         :integer(4)      not null, primary key
  entry_id   :integer(4)
  place_id   :integer(4)
  string     :string(255)
  context    :string(255)
  confidence :integer(4)

=end Schema Information

class PlaceDetermination < ActiveRecord::Base
  belongs_to :entry
  belongs_to :place
end

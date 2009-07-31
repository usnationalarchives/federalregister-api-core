=begin Schema Information

 Table name: referenced_dates

  id         :integer(4)      not null, primary key
  entry_id   :integer(4)
  date       :date
  string     :string(255)
  context    :string(255)
  created_at :datetime
  updated_at :datetime
  date_type  :string(255)

=end Schema Information

class ReferencedDate < ActiveRecord::Base
  belongs_to :entry
end

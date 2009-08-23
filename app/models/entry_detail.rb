=begin Schema Information

 Table name: entry_details

  id            :integer(4)      not null, primary key
  entry_id      :integer(4)
  full_text_raw :text(2147483647

=end Schema Information

class EntryDetail < ActiveRecord::Base
  belongs_to :entry
end

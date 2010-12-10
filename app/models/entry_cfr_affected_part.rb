=begin Schema Information

 Table name: entry_cfr_affected_parts

  id       :integer(4)      not null, primary key
  entry_id :integer(4)
  title    :integer(4)
  part     :integer(4)

=end Schema Information

class EntryCfrAffectedPart < ApplicationModel
  belongs_to :entry
end

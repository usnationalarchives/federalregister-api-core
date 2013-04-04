# == Schema Information
#
# Table name: dictionary_words
#
#  id         :integer(4)      not null, primary key
#  word       :string(255)
#  created_at :datetime
#  creator_id :integer(4)
#

class DictionaryWord < ApplicationModel
  validates_presence_of :word
end

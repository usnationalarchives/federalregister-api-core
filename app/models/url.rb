=begin Schema Information

 Table name: urls

  id             :integer(4)      not null, primary key
  name           :string(255)
  type           :string(255)
  content_type   :string(255)
  response_code  :integer(4)
  content_length :float
  title          :string(255)
  created_at     :datetime
  updated_at     :datetime

=end Schema Information

class Url < ActiveRecord::Base
  has_many :url_references
  has_many :entries, :through => :url_references
end

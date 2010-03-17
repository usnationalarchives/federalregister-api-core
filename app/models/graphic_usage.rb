=begin Schema Information

 Table name: graphic_usages

  id         :integer(4)      not null, primary key
  graphic_id :integer(4)
  entry_id   :integer(4)

=end Schema Information

class GraphicUsage < ActiveRecord::Base
  belongs_to :entry
  belongs_to :graphic, :counter_cache => :usage_count
end

class GraphicUsage < ApplicationModel
  belongs_to :entry
  belongs_to :graphic, :counter_cache => :usage_count
end

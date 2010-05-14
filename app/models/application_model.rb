class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true
  
  class << self
    public :preload_associations
  end
end
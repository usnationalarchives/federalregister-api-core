class EntryImporter
  module Utils
    def included(klass)
      klass.instance_eval do
        cattr_accessor :provided
        self.provided = [] unless self.provided.present?
      end
      
      klass.provided = klass.provided + @attributes
    end
    
    def provides(*attributes)
      @attributes ||= []
      @attributes += attributes
    end
  end
end
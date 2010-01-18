class ActiveRecord::SerializationError < StandardError; end

class ActiveRecord::Base
  # TODO: pluginize
  def self.serializable_column(*attributes)
    
    attributes.each do |attribute|
      define_method "#{attribute}=" do |val|
        self[attribute] = case val
                          when String
                            val
                          else
                            begin
                              ActiveSupport::JSON::encode(val)
                            rescue Exception => e
                              raise ActiveRecord::SerializationError.new("could not serialize object of class '#{val.class}': #{val.inspect}")
                            end
                          end
      end

      define_method attribute do
        if self[attribute].present?
           ActiveSupport::JSON::decode(self[attribute])
        else
          nil
        end
      end
      
    end
  end
  
  # TODO: pluginize
  def self.file_attribute(attribute, &filename_generator)
    require 'ftools'
    
    path_method = "#{attribute}_file_path"
    define_method path_method do
      instance_eval(&filename_generator)
    end
    
    define_method "#{attribute}=" do |val|
      path = self.send(path_method)
      File.makedirs(File.dirname(path))
      self.class.transaction do 
        if self.class.columns_hash["#{attribute}_created_at"] && self["#{attribute}_created_at"].nil?
          self["#{attribute}_created_at"] = Time.now
        end
        
        if self.class.columns_hash["#{attribute}_updated_at"]
          self["#{attribute}_updated_at"] = Time.now
        end
        
        File.open(path, 'w') {|f| f.write(val) }
        save
      end
    end

    define_method attribute do
      path = self.send(path_method)
      File.read(path)
    end
  end
  
end
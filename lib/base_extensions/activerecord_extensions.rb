class ActiveRecord::SerializationError < StandardError; end

class ActiveRecord::Base
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
end
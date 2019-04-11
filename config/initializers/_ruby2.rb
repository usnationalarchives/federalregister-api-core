# patch for Rails 2.x with Ruby 2+
# TODO: BB remove after upgrade
if Rails::VERSION::MAJOR == 2 && RUBY_VERSION >= '2.0.0'

  # fixes issue with loading yml files for i18n
  module I18n
    module Backend
      module Base
        def load_file(filename)
          type = File.extname(filename).tr('.', '').downcase
          # As a fix added second argument as true to respond_to? method
          raise UnknownFileType.new(type, filename) unless respond_to?(:"load_#{type}", true)
          data = send(:"load_#{type}", filename) # TODO raise a meaningful exception if this does not yield a Hash
          data.each { |locale, d| store_translations(locale, d) }
        end
      end
    end
  end

  # fixes issue that causes 'undefined method `insert_record' for #<Array:' for active_record
  module ActiveRecord
    module Associations
      class AssociationProxy
        def send(method, *args)
          if proxy_respond_to?(method, true)
            super
          else
            load_target
            @target.send(method, *args)
          end
        end
      end
    end
  end

  # The filter_parameter_logging method, used to filter request parameters
  # (such as passwords) from the log, defines a protected method called
  # filter_parameter when called. Its existence is later tested using
  # respond_to?, without the include_private parameter. Due to the respond_to?
  # behavior change, the method existence is never detected, and parameter
  # filtering stops working.
  require 'action_controller'

  module ParameterFilterPatch
    def respond_to?(method, include_private = false)
      if method.to_s == 'filter_parameters'
        include_private = true
      end

      super(method, include_private)
    end
  end

  module ActionController
    class Base
      prepend ParameterFilterPatch
    end
  end
end

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
# # Use deployed git commit hash as quick & easy cache busting strategy
ENV["RAILS_ASSET_ID"] = `git log -n 1 --pretty=format:%H`

if (File.basename($0) == 'rake' && (ARGV.include?('db:migrate')|| ARGV.include?('db:setup')))
  ENV["ASSUME_UNITIALIZED_DB"] = '1'
end

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '3.1.12' unless defined? RAILS_GEM_VERSION

# # Bootstrap the Rails environment, frameworks, and default configuration
# require File.join(File.dirname(__FILE__), 'boot')


# # require our patched logger
# require File.join(RAILS_ROOT, "lib", "binary_buffered_logger")

# patch for Rails 2.x with Ruby 2+
# TODO: BB remove after upgrade
# if Rails::VERSION::MAJOR == 2 && RUBY_VERSION >= '2.0.0'
#   module Gem
#     def self.source_index
#       sources
#     end
#     def self.cache
#       sources
#     end
#     SourceIndex = Specification
#     class SourceList
#       # If you want vendor gems, this is where to start writing code.
#       def search(*args); []; end
#       def each(&block); end
#       include Enumerable
#     end
#   end
# end

# # ensure /usr/local/bin is in our path
# ENV["PATH"]="#{ENV["PATH"]}:/usr/local/bin"

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
FederalregisterApiCore::Application.initialize!


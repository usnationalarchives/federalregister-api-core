Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
# # Use deployed git commit hash as quick & easy cache busting strategy
ENV["RAILS_ASSET_ID"] = `git log -n 1 --pretty=format:%H`

if (File.basename($0) == 'rake' && (ARGV.include?('db:migrate')|| ARGV.include?('db:setup')))
  ENV["ASSUME_UNITIALIZED_DB"] = '1'
end

# ensure /usr/local/bin is in our path
ENV["PATH"]="#{ENV["PATH"]}:/usr/local/bin"

# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

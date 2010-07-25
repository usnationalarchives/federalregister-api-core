require 'sass'
if RAILS_ENV == 'development'
  Sass::Plugin.options[:style] = :expanded
else
  Sass::Plugin.options[:style] = :compressed
end
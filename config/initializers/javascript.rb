initial_libs = ['jquery.js', 'jrails.js']
vendor_libs = Dir.entries("#{RAILS_ROOT}/public/javascripts/vendor").select{|n| n =~ /\.js$/}.sort
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :vendor => initial_libs + (vendor_libs - initial_libs)
initial_libs = ['jquery-1.6.1.min.js', 'jrails.js']
exclude_libs = ['vendor.js', 'vendor-20120907.js', 'vendor-20121119.js']
all_vendor_libs = Dir.entries("#{RAILS_ROOT}/public/javascripts/vendor").select{|n| n =~ /\.js$/}.sort

vendor_lib_list = (initial_libs + (all_vendor_libs - initial_libs - exclude_libs)).map{|filename| "vendor/#{filename}"}
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :vendor => vendor_lib_list

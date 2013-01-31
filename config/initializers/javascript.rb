VENDOR_INITIAL_LIBS = ['jquery-1.8.3.min.js', 'jrails.js', 'jquery-ui-1.9.2.custom.min.js', 'jquery-ui-1.9.2.effects.min.js']
ALL_VENDOR_LIBS = Dir.entries("#{RAILS_ROOT}/public/javascripts/vendor").select{|n| n =~ /\.js$/}.sort

vendor_lib_list = (VENDOR_INITIAL_LIBS + (ALL_VENDOR_LIBS - VENDOR_INITIAL_LIBS)).map{|filename| "vendor/#{filename}"}
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :vendor => vendor_lib_list


initial_libs = ['fr_index_popover_handler.js']
all_libs = Dir.entries("#{RAILS_ROOT}/public/javascripts/").select{|n| n =~ /\.js$/}.sort
lib_list = (initial_libs + (all_libs - initial_libs)).map{|filename| "#{filename}"}
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :non_vendor => lib_list


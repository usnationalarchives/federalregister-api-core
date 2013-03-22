# if you're adding a file to vendor - especially initial libs 
# then check to make sure that closure doesn't have/need an extern file
# http://closure-compiler.googlecode.com/svn/trunk/contrib/externs/
VENDOR_INITIAL_LIBS = ['jrails.js', 'jquery-ui-1.9.2.custom.min.js', 'jquery-ui-1.9.2.effects.min.js']
ALL_VENDOR_LIBS = Dir.entries("#{RAILS_ROOT}/public/javascripts/vendor").select{|n| n =~ /\.js$/}.sort
vendor_exclude_libs = ['vendor-2013-02-26.js']
if Rails.env == "development"
  vendor_lib_list = (VENDOR_INITIAL_LIBS + (ALL_VENDOR_LIBS - VENDOR_INITIAL_LIBS - vendor_exclude_libs)).map{|filename| "vendor/#{filename}"}
else
  vendor_lib_list = (VENDOR_INITIAL_LIBS + (ALL_VENDOR_LIBS - VENDOR_INITIAL_LIBS)).map{|filename| "vendor/#{filename}"}
end
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :vendor => vendor_lib_list


initial_libs = ['fr_index_popover_handler.js']
all_libs = Dir.entries("#{RAILS_ROOT}/public/javascripts/").select{|n| n =~ /\.js$/}.sort
lib_list = (initial_libs + (all_libs - initial_libs)).map{|filename| "#{filename}"}
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :non_vendor => lib_list


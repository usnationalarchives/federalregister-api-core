ActionView::Helpers::AssetTagHelper.register_javascript_expansion :vendor => Dir.glob('public/javascripts/vendor/*.js').map{|s| s.sub(/public\/javascripts\//,'')} - ['vendor/vendor.js']

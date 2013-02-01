namespace :closure_compiler do 
  namespace :create do
    task :vendor_js => :environment do
      options = []

      vendor_lib_list = (VENDOR_INITIAL_LIBS + (ALL_VENDOR_LIBS - VENDOR_INITIAL_LIBS))
      vendor_lib_list.each do |lib|
        options << "--js public/javascripts/vendor/#{lib}"
      end
      
      vendor_extern_list = Dir.entries("#{RAILS_ROOT}/public/javascripts/vendor/externs").select{|n| n =~ /\.js$/}
      vendor_extern_list.each do |lib|
        options << "--externs public/javascripts/vendor/externs/#{lib}"
      end

      puts `rm public/javascripts/vendor/vendor-#{Time.new.strftime("%Y-%m-%d")}.js; java -jar compiler.jar #{options.join(' ')} --js_output_file public/javascripts/vendor/vendor-#{Time.new.strftime("%Y-%m-%d")}.js --compilation_level SIMPLE_OPTIMIZATIONS`
    end
  end
end


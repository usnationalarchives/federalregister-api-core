namespace :closure_compiler do 
  namespace :create do
    task :vendor_js => :environment do
      vendor_lib_list = (VENDOR_INITIAL_LIBS + (ALL_VENDOR_LIBS - VENDOR_INITIAL_LIBS)).map{|filename| "public/javascripts/vendor/#{filename}"}
      vendor_extern_list = Dir.entries("#{RAILS_ROOT}/public/javascripts/vendor/externs").select{|n| n =~ /\.js$/}.map{|filename| "public/javascripts/vendor/externs/#{filename}"}

      puts `rm public/javascripts/vendor/vendor-#{Time.new.strftime("%Y-%m-%d")}.js; java -jar compiler.jar #{vendor_lib_list.join(' --js ')} #{vendor_extern_list.join(' --externs ')} --js_output_file public/javascripts/vendor/vendor-#{Time.new.strftime("%Y-%m-%d")}.js --compilation_level SIMPLE_OPTIMIZATIONS`
    end
  end
end


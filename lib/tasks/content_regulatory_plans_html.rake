namespace :content do
  namespace :regulatory_plans do
    namespace :html do
      namespace :compile  do
        def compile_type_for_all(type)
          require 'fileutils'
          root_dir = "#{RAILS_ROOT}/data/regulatory_plans/html/#{type}"
          File.makedirs(root_dir)
          
          RegulatoryPlan.in_current_issue.find_each do |regulatory_plan|
            puts "rendering #{type} for #{regulatory_plan.regulation_id_number}"
            val = Content.render_erb("regulatory_plans/_#{type}", {:regulatory_plan => regulatory_plan})
            File.open("#{root_dir}/#{regulatory_plan.regulation_id_number}.html", 'w') {|f| f.write(val) }
          end
        end
        
        desc "Compile all HTML for regulatory plans"
        task :all => [:contacts, :full_text, :sidebar]
        
        desc "Compile contact HTML for regulatory plans"
        task :contacts => :environment do
          compile_type_for_all('contacts')
        end
        
        desc "Compile full text HTML for regulatory plans"
        task :full_text => :environment do
          compile_type_for_all('full_text')
        end
        
        desc "Compile sidebar HTML for regulatory plans"
        task :sidebar => :environment do
          compile_type_for_all('sidebar')
        end
      end
    end
  end
end

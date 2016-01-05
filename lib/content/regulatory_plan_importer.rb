module Content
  class RegulatoryPlanImporter
    require 'ftools'

    def self.recalculate_current
      ActiveRecord::Base.connection.execute("UPDATE regulatory_plans SET current = 1")
      ActiveRecord::Base.connection.execute("UPDATE regulatory_plans, regulatory_plans prior_reg_plan
                                            SET regulatory_plans.current = 0
                                            WHERE regulatory_plans.regulation_id_number = prior_reg_plan.regulation_id_number
                                            AND prior_reg_plan.issue > regulatory_plans.issue")
    end
    
    def self.import_all_small_entities
      RegulatoryPlan.find_each do |reg_plan|
        puts "#{reg_plan.issue}: #{reg_plan.regulation_id_number}"
        root_node = reg_plan.send(:root_node)
        if root_node
          small_entities = root_node.xpath('.//SMALL_ENTITY').map(&:content).map do |name|
            next if name == 'No' || name == 'Undetermined'
            SmallEntity.find_or_initialize_by_name(name)
          end
          reg_plan.small_entities = small_entities.compact
          reg_plan.save
        else
          puts "XML NOT AVAILABLE!"
        end
      end
    end

    def self.import_all_by_publication_date(issue)
      url = "http://www.reginfo.gov/public/do/eAgendaMain?operation=OPERATION_GET_AGENCY_RULE_LIST&currentPubId=#{issue}&agencyCd=0000"
      path = "#{Rails.root}/data/regulatory_plans/xml/#{issue}/index.html"
      download_url_to(url, path)
      doc = Nokogiri::HTML(File.read(path))
    
      regulation_id_numbers = doc.css('td a.pageSubNavTxt').map{|a| a.content().gsub(/\s*/, '') }
      regulation_id_numbers.each do |regulation_id_number|
        RegulatoryPlanImporter.new(issue, regulation_id_number).perform
      end
    end
  
    attr_reader :issue, :regulation_id_number, :regulatory_plan
    def initialize(issue, regulation_id_number)
      @issue = issue
      @regulation_id_number = regulation_id_number
    
      @regulatory_plan = RegulatoryPlan.find_by_regulation_id_number_and_issue(@regulation_id_number, @issue) || RegulatoryPlan.new(:regulation_id_number => @regulation_id_number, :issue => @issue)
    end
  
    def perform
      return unless document
      %w(title abstract priority_category events agency_name_assignments small_entities).each do |attr|
        @regulatory_plan.send("#{attr}=", self.send(attr))
      end
      @regulatory_plan.save
    end
  
    def file_path
      @regulatory_plan.full_xml_file_path
    end
  
    def document
      self.class.download_url_to(@regulatory_plan.source_url(:xml), file_path)
      doc = Nokogiri::XML(open(file_path))
      if doc.root.name == "REGINFO_RIN_DATA"
        doc.root
      else
        nil
      end
    end
  
    def title
      document.xpath('.//RULE_TITLE').first.content
    end
  
    def abstract
      document.xpath('.//ABSTRACT').first.content
    end
  
    def priority_category
      document.xpath('.//PRIORITY_CATEGORY').first.content
    end

    def small_entities
      document.xpath('.//SMALL_ENTITY').map(&:content).reject{|e| e == 'No' || e == 'Undetermined'}.map do |name|
        SmallEntity.find_or_initialize_by_name(name)
      end
    end
    
    def agency_name_assignments
      @regulatory_plan.agencies = []
      @regulatory_plan.agency_name_assignments = []
      assignments = document.css('RIN_INFO > AGENCY NAME, RIN_INFO > PARENT_AGENCY NAME').map do |agency_node|
        name = agency_node.content()
        agency_name = AgencyName.find_or_create_by_name(name)
        AgencyNameAssignment.new(:agency_name => agency_name)
      end
      
      assignments.reverse
    end
  
    def events
      document.xpath('.//TIMETABLE_LIST/TIMETABLE').map do |timetable_node|
        action = timetable_node.xpath('./TTBL_ACTION').first.content
        date = timetable_node.xpath('./TTBL_DATE').first.try(:content)
      
        if date
          if date == 'To Be Determined'
            date = nil
          else
            date = date.sub(/(\d{2})\/(\d{2})\/(\d{4})/, '\3-\1-\2')
          end
        end
        fr_citation = timetable_node.xpath('./FR_CITATION').first.try(:content)
      
        @regulatory_plan.events.to_a.find{|e| e.action == action and e.date == date && e.fr_citation == fr_citation} || RegulatoryPlanEvent.new(:action => action, :date => date, :fr_citation => fr_citation)
      end
    end
    
    def self.download_url_to(url, path)
      File.makedirs(File.dirname(path))
      unless File.exists?(path)
        FederalRegisterFileRetriever.download(url, path)
      end
      
    end
  end
end

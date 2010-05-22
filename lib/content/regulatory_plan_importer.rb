module Content
  class RegulatoryPlanImporter
    require 'ftools'
    
    def self.import_all_by_publication_date(issue)
      url = "http://www.reginfo.gov/public/do/eAgendaMain?operation=OPERATION_GET_AGENCY_RULE_LIST&currentPubId=#{issue}&agencyCd=0000"
      puts url
      response = Curl::Easy.http_get(url)
      doc = Nokogiri::HTML(response.body_str)
    
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
      %w(title abstract priority_category events).each do |attr|
        @regulatory_plan.send("#{attr}=", self.send(attr))
      end
      @regulatory_plan.save
    end
  
    def url
      "http://www.reginfo.gov/public/do/eAgendaViewRule?pubId=#{issue}&RIN=#{regulation_id_number}&operation=OPERATION_EXPORT_XML"
    end
  
    def file_path
      @regulatory_plan.full_xml_file_path
    end
  
    def document
      File.makedirs(File.dirname(file_path))
      Curl::Easy.download(url, file_path) unless File.exists?(file_path)
      doc = Nokogiri::XML(open(file_path))
      doc.root
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
  end
end
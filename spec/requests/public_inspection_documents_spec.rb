RSpec.describe "Public Inspection API", :type => :request, :es => true do

  it "can query simple serializer attributes AND attributes defined by a proc" do
    pi_doc = Factory(:public_inspection_document)
    get "/api/v1/public-inspection-documents/#{pi_doc.document_number}.json?fields[]=document_number&fields[]=filed_at"
    expect(response).to have_http_status(200)
  end

  context "#show" do
    it "serialized attributes as expected" do
      current_time = Time.current
      pi_doc = Factory(:public_inspection_document,
        "category"=>"Administrative Orders",
        "created_at"=> current_time,
        "document_file_path"=>"202/221/844",
        "document_number"=>"2022-21844",
        "editorial_note"=>nil,
        "entry_id"=>nil,
        "filed_at"=> current_time,
        "granule_class"=>"PRESDOCU",
        "num_pages"=>1,
        "pdf_file_name"=>"2022-21844_PI.pdf",
        "pdf_file_size"=>62345,
        "pdf_updated_at"=> current_time.as_json,
        "pdf_url"=>"/containers/binary/3604714",
        "publication_date"=> Date.current,
        "raw_text_updated_at"=> current_time,
        "special_filing"=>true,
        "subject_1"=>"Government Organization and Employees:",
        "subject_2"=>"Management and Budget, Office of; Delegation of Authority Under Public Law 117-169 (Memorandum of September 30, 2022)",
        "subject_3"=>nil,
        "update_pil_at"=> current_time,
        "updated_at"=> current_time
      )

      get "/api/v1/public-inspection-documents/#{pi_doc.document_number}.json"
      json_response = JSON.parse(response.body)
      json_response.delete("filed_at") #Remove spec check due to negligible time diffs
      json_response.delete("pdf_updated_at") #Remove spec check due to negligible time diffs

      expect(json_response).to include({
        "agencies"=>                                          [],
         "agency_letters"=>[],                                 
         "agency_names"=>[],
         "docket_numbers"=>[],                                 
         "document_number"=>"2022-21844",                      
         "editorial_note"=>nil,                                
        #  "filed_at"=>current_time,          
         "filing_type"=>"special",                             
         "html_url"=>"http://www.fr2.local:8081/public-inspection/2022-21844/government-organization-and-employees-management-and-budget-office-of-delegation-of-authority-under",
         "last_public_inspection_issue"=>nil,
         "num_pages"=>1,
         "page_views"=>{"count"=>0, "last_updated"=>nil},
         "pdf_file_name"=>"2022-21844_PI.pdf",
         "pdf_file_size"=>62345,
        #  "pdf_updated_at"=>current_time,
         "pdf_url"=>"https://public-inspection.example.org/2022-21844.pdf",
         "publication_date"=>Date.current.to_s(:iso),
         "raw_text_url"=>"http://www.fr2.local:8081/public-inspection/raw_text/202/221/844.txt",
         "subject_1"=>"Government Organization and Employees:",
         "subject_2"=>"Management and Budget, Office of; Delegation of Authority Under Public Law 117-169 (Memorandum of September 30, 2022)",
         "subject_3"=>nil,
         "title"=>"Government Organization and Employees: Management and Budget, Office of; Delegation of Authority Under Public Law 117-169 (Memorandum of September 30, 2022) ",
         "toc_doc"=>"Management and Budget, Office of; Delegation of Authority Under Public Law 117-169 (Memorandum of September 30, 2022)",
         "toc_subject"=>"Government Organization and Employees:",
         "type"=>"Presidential Document"
      })
    end

  end
end

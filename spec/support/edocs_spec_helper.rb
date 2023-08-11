module EdocsSpecHelper

  def create_sample_pi_doc_xml_node!
    pi_doc_node_xml = <<-XML
      <Document>
        <DocumentNumber>2023-16252</DocumentNumber>                                                                     
        <Agencies>                                                                                                      
          <Agency>Centers for Medicare &amp; Medicaid Services<CFR><CFRTitle>42</CFRTitle><CFRPart>411,412,419,488,489,495</CFRPart></CFR></Agency>
        </Agencies>                                                                                                     
        <DocumentType>RULES</DocumentType>                                                                             
        <FilingSection>Special</FilingSection>                                                                         
        <Title/>                                     
        <Category>RULES</Category>                   
        <SpecialRequestType>IMMEDIATE FILE</SpecialRequestType>
        <ForceToSpecialFiling>0</ForceToSpecialFiling>
        <PresidentialHeader/>                        
        <SubjectLine>Medicare Program:</SubjectLine> 
        <Subject2>Hospital Inpatient Prospective Payment Systems for Acute Care Hospitals and the Long Term Care Hospital Prospective Payment System and Policy Changes, etc.</Subject2>
        <Subject3/>                                  
        <FiledAt>2023-08-01T16:15:00.000000000</FiledAt>
        <FileUntil/>
        <PILUpdateTime/>
        <DateKill/>
        <PublicationDate>2023-08-28T00:00:00.000000000</PublicationDate>
        <PublicInspectionDate>2023-08-01T16:15:00.000000000</PublicInspectionDate>
        <Docket/>
        <RIN>0938-AV08; 0938-AV17</RIN>
        <EditorialNote/>
        <URL>containers/binary/3983615</URL>
      </Document>
    XML

    doc = Nokogiri::XML(pi_doc_node_xml)
    doc.at('Document')
  end

end

class PublicInspectionScrapingCorrector

  def perform
    PublicInspectionDocument.transaction do
      docs_to_update.each do |original, corrected|
        doc = PublicInspectionDocument.find_by_document_number(original)
        puts "cleaning up doc #{doc.document_number}..."
        if doc
          if corrected
            doc.update_attributes(document_number: corrected)
          else
            doc.destroy
          end
        end
      end
    end
  end


  private

  def docs_to_update
    {
      'Republication with Correction 2012-07295' => '2012-07295',
      'Correction C1-2012-00019' => nil,
      'Change to the Compliance Date for ICD 10 CM and ICD 10 PCS Medical Data Code Sets 2012-08718'                => nil,
      ': 2012-09746'             => nil,
      'Correction C1-2012-27143' => nil,
      'Toad'                     => nil,
      '2014--10067'              => nil,
      'R1--2014-15337'           => nil,
      'Correction'               => nil,
      'C1-2015--01046'           => nil,
      '2014--10306'              => nil,
      '2014--11879'              => nil,
      '2014--11843'              => nil,
      '2014--12697'              => nil,
      '2014--12700'              => nil,
      '2014--14039'              => nil,
      '2014--14760'              => nil,
      '2014--14762'              => nil,
      '2014--12167'              => nil,
      '2014--17416'              => nil,
      '2014--18295'              => nil,
      '2014--21576'              => nil,
      '2014--21524'              => nil,
      '2014--20838'              => nil,
      '2014--21687'              => nil,
      '2014--23750'              => nil,
      '2014--24661'              => nil,
      '2014--25248'              => nil,
      '2014--25445'              => nil,
      '2014--25701'              => nil,
      '2014--25558'              => nil,
      '2014--26664'              => nil,
      '2014--29355'              => nil,
      '2014--29779'              => nil,
      '2014--29693'              => nil,
      '2014--30462'              => nil,
      '2015--00913'              => nil,
      '2015--01273'              => nil,
      '2015--02851'              => nil,
    }
  end

end

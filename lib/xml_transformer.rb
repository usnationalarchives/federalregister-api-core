module XmlTransformer
  def transform_xml(xml, stylesheet, options={})
    xslt  = Nokogiri::XSLT(
      File.read("#{RAILS_ROOT}/app/views/#{stylesheet}"),
      "http://federalregister.gov/functions" => XsltFunctions
    )
    xslt.transform(Nokogiri::XML(xml), options.to_a.flatten)
  end
end

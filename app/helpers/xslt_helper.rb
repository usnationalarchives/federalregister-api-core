module XsltHelper
  def transform_xml(xml, stylesheet)
    xslt  = Nokogiri::XSLT(File.read("#{RAILS_ROOT}/app/views/#{stylesheet}"))
    xslt.transform(Nokogiri::XML(xml))
  end
end
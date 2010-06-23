module XsltHelper
  def transform_xml(xml, stylesheet, options = {})
    xslt  = Nokogiri::XSLT(File.read("#{RAILS_ROOT}/app/views/#{stylesheet}"))
    xslt.transform(Nokogiri::XML(xml), options.to_a.flatten)
  end
end
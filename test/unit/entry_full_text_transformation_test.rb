require 'test_helper'

module EntryFullTextTransformationTestHelpers
  # include helper module to do XSLT transformations
  include XmlTransformer
  
  # provide sample bulkdata XML and return the transformed version
  def process(xml)
    @html = transform_xml("<RULE>#{xml}</RULE>", "entries/_full_text.html.xslt")
  end 
  
  # include the standard rails view testing support
  include ActionController::Assertions::SelectorAssertions
  # but override it to look at what was defined by the `process` method, rather than what is returned by the normal view layer
  def response_from_page_or_rjs
    HTML::Document.new("<html>#{@html}</html>").root
  end
end

class EntryFullTextTransformationTest < ActiveSupport::TestCase
  include EntryFullTextTransformationTestHelpers
  
  def test_headers
    process <<-XML
       <HD SOURCE="HD1">Header 1</HD>
       <HD SOURCE="HD2">Header 2</HD>
       <HD SOURCE="HD3">Header 3</HD>
       <HD SOURCE="HD4">Header 4</HD>
     XML
     
     assert_select "h3", :text => 'Header 1'
     assert_select "h4", :text => 'Header 2'
     assert_select "h5", :text => 'Header 3'
     assert_select "h6", :text => 'Header 4'
  end
end
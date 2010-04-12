module XsltHelperSpecHelpers
  include XsltHelper
  
  def process(xml)
    @html = transform_xml("<RULE>#{xml}</RULE>", "entries/_full_text.html.xslt").to_s
  end
end

describe XsltHelper do
  require 'webrat'
  include Webrat::HaveTagMatcher
  include XsltHelperSpecHelpers
  
  describe 'emphasized text' do
    it 'should add spaces around it when surrounded by word characters' do
      process <<-XML
        <P>John's<E T="03">ex parte</E>rules</P>
      XML
      
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "John's <span class=\"E-03\">ex parte</span> rules"
      end
    end
  end
end
module XsltHelperSpecHelpers
  include XsltHelper
  
  def process(xml)
    @html = transform_xml("<RULE>#{xml}</RULE>", "entries/_full_text.html.xslt",{'first_page' => 100.to_s, 'volume' => '77' }).to_s
  end
end

describe XsltHelper do
  require 'webrat'
  include Webrat::HaveTagMatcher
  include XsltHelperSpecHelpers
  
  describe 'emphasized text' do
    it 'adds spaces around it when surrounded by word characters' do
      process <<-XML
        <P>John's<E T="03">ex parte</E>rules</P>
      XML
      
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "John's <span class=\"E-03\">ex parte</span> rules"
      end
    end
    
    it 'adds a space before it when preceded by a comma or a space' do
      process <<-XML
        <P>or,<E T="03">decision</E>.<E T="03">decision</E> was</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "or, <span class=\"E-03\">decision</span>. <span class=\"E-03\">decision</span> was"
      end
    end
    
    it 'adds a space before it when preceded by a word character' do
      process <<-XML
        <P>John'S<E T="03">decision</E>.</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "John'S <span class=\"E-03\">decision</span>."
      end
    end
    
    it 'does not add a space before it when not preceded by a word character' do
      process <<-XML
        <P>John's "<E T="03">decision</E>".</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "John's \"<span class=\"E-03\">decision</span>\"."
      end
    end
    
    it 'includes a space after it when followed by a word character' do
      process <<-XML
        <P>--<E T="03">text</E>is not a good idea</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "--<span class=\"E-03\">text</span> is not a good idea"
      end
    end
    
    it 'does not include a space after it when followed by a non-word character' do
      process <<-XML
        <P>Fish <E T="03">text</E>--is not a good idea</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "Fish <span class=\"E-03\">text</span>--is not a good idea"
      end
    end
  end
end

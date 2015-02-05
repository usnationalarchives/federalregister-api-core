require "spec_helper"
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
        p.first.inner_html.should == "John's <i class=\"E-03\">ex parte</i> rules"
      end
    end
    
    it 'adds a space before it when preceded by a comma or a space' do
      process <<-XML
        <P>or,<E T="03">decision</E>.<E T="03">decision</E> was</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "or, <i class=\"E-03\">decision</i>. <i class=\"E-03\">decision</i> was"
      end
    end
    
    it 'adds a space before it when preceded by a word character' do
      process <<-XML
        <P>John'S<E T="03">decision</E>.</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "John'S <i class=\"E-03\">decision</i>."
      end
    end
    
    it 'does not add a space before it when not preceded by a word character' do
      process <<-XML
        <P>John's "<E T="03">decision</E>".</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "John's \"<i class=\"E-03\">decision</i>\"."
      end
    end
    
    it 'includes a space after it when followed by a word character' do
      process <<-XML
        <P>--<E T="03">text</E>is not a good idea</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "--<i class=\"E-03\">text</i> is not a good idea"
      end
    end
    
    it 'does not include a space after it when followed by a non-word character' do
      process <<-XML
        <P>Fish <E T="03">text</E>--is not a good idea</P>
      XML
      @html.should have_tag("p") do |p|
        p.first.inner_html.should == "Fish <i class=\"E-03\">text</i>--is not a good idea"
      end
    end

    it "does include a space after it when followed by a section symbol" do
      process <<-XML
        <P><E T="03">See</E>&#xA7; 1026</P>
      XML

      @html.should have_tag("p") do |p|
        p.first.inner_html.should == " <i class=\"E-03\">See</i> &sect; 1026"
      end
    end
  end
end

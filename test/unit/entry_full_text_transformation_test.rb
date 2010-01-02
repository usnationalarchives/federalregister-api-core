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
  
  context 'headers' do
    should "become h* tags, downgraded two levels" do
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
  
  context "simple gpotable" do
    should "map directly to HTML tables" do
      process <<-XML
        <GPOTABLE COLS="2">
          <BOXHD>
            <CHED H="1">First Name</CHED>
            <CHED H="1">Last Name</CHED>
          </BOXHD>
          <ROW>
            <ENT>John</ENT>
            <ENT>Doe</ENT>
          </ROW>
          <ROW>
            <ENT>Jane</ENT>
            <ENT>Doe</ENT>
          </ROW>
        </GPOTABLE>
      XML
    
      assert_select "table" do
        assert_select "thead tr", 1
        assert_select "thead tr th", 2
        assert_select "tbody tr" do |rows|
          rows.each do |row|
            assert_select row, "td", 2
          end
        end
      end
    end
  end
  
  context "two-level table header" do
    setup do
      process <<-XML
        <GPOTABLE COLS="5">
          <BOXHD>
            <CHED H="1"></CHED>
            <CHED H="1">California</CHED>
            <CHED H="2">Population</CHED>
            <CHED H="2">Area</CHED>
            <CHED H="1">Oregon</CHED>
            <CHED H="2">Population</CHED>
            <CHED H="2">Area<EM>1</EM></CHED>
          </BOXHD>
        </GPOTABLE>
      XML
    end
    
    should "have two header rows" do
      assert_select "table thead tr", 2
    end
      
    should "have three headers in the first header row" do
      assert_select "table thead tr" do |header_rows|
        assert_select header_rows.first, "th", 3
      end
    end
    
    should "span multiple columns in some cells" do
      assert_select "table thead tr" do |header_rows|
        assert_select header_rows.first, "th:nth-of-type(1)[colspan]", 0
        assert_select header_rows.first, "th:nth-of-type(2)[colspan=2]"
        assert_select header_rows.first, "th:nth-of-type(3)[colspan=2]"
      end
    end
    
    should_eventually "span multiple rows in some cells" do 
      assert_select "th:first-of-type[rowspan=2]"
    end
  end
  
  context "three-level table header" do
    setup do
      process <<-XML
        <GPOTABLE COLS="5">
          <BOXHD>
            <CHED H="1">System designation</CHED>
            <CHED H="1">Light source composition</CHED>
            <CHED H="1">Photometry requirements reference</CHED>
            <CHED H="2">Table XVIII</CHED>
            <CHED H="3">Upper beam mechanical and visual aim</CHED>
            <CHED H="2">Tables XIX-a, XIX-b, XIX-c</CHED>
            <CHED H="3">Lower beam mech aim</CHED>
            <CHED H="3">Lower beam visual aim</CHED>
          </BOXHD>
        </GPOTABLE>
      XML
    end
    
    should "have three header rows" do
      assert_select "table thead tr", 3
    end
      
    should "have three headers in the first header row" do
      assert_select "table thead tr" do |header_rows|
        assert_select header_rows.first, "th", 3
      end
    end
    
    # should "span multiple columns in some cells" do
    #   assert_select "table thead tr" do |header_rows|
    #     assert_select header_rows.second, "th:nth-of-type(3)[colspan=2]"
    #     assert_select header_rows.second, "th:nth-of-type(4)[colspan=2]"
    #   end
    # end
  end
  
  context "complex table body" do
    setup do 
      process <<-XML
      <GPOTABLE CDEF="s25,12,12,12" COLS="4" OPTS="L2,i1">
        <BOXHD>
          <CHED H="1"/>
          <CHED H="1">Mango</CHED>
          <CHED H="1">Mangosteen</CHED>
          <CHED H="1">Pineapple</CHED>
        </BOXHD>
        <ROW RUL="s">
          <ENT I="22"/>
          <ENT A="02">1,000 lb</ENT>
        </ROW>
        <ROW>
          <ENT I="01">2000</ENT>
          <ENT>528,868</ENT>
          <ENT>40</ENT>
          <ENT>711,292</ENT>
        </ROW>
        <TNOTE>Note: all figures are approximate.</TNOTE>
        <TNOTE>Source: FAOSTAT data, 2006.</TNOTE>
        <SIGDAT>Lorem ipsum</SIGDAT>
        <TDESC>This is a description</TDESC>
      </GPOTABLE>
      XML
    end
    
    should "respect the a attribute on ENT elements" do
      assert_select "table tbody tr:first-of-type td", 2
      assert_select "table tbody tr:first-of-type td:last-of-type[colspan=3]", 1
      
      assert_select "table tbody tr:nth-of-type(2) td:not([colspan])", 4
    end
    
    context "note rows" do
      should "have a particular class" do
        assert_select "table tbody tr.TNOTE", 2
        assert_select "table tbody tr.SIGDAT", 1
        assert_select "table tbody tr.TDESC", 1
      end
    
      should "span all columns" do
        assert_select "tr.TNOTE td[colspan=4], tr.SIGDAT td[colspan=4], tr.TDESC td[colspan=4]", 4
      end
    end
  end
  
end
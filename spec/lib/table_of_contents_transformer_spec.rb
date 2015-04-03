require 'spec_helper'

describe TableOfContentsTransformer do

  describe 'Agency-lookup and cross-referencing' do
    it "AgencyName matches an existing Agency" do
      agency = Agency.create(name: "Test Agency", slug: "test-slug", url: "http://wwww.test.com")
      agency.agency_names << AgencyName.create(name: "Agency Test")
      transformer = TableOfContentsTransformer.new('2015-01-01')
      agency_representation = transformer.create_agency_representation_struct("Agency Test")
      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "test-agency"
      agency_representation.url.should == "http://wwww.test.com"
    end

    it "Provided agency name matches AgencyName but no matching Agency" do
      AgencyName.create(name: "Agency Test")
      transformer = TableOfContentsTransformer.new('2015-01-01')
      agency_representation = transformer.create_agency_representation_struct("Agency Test")
      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "agency-test"
      agency_representation.url.should == ""
    end

    it "Provided agency does not match any AgencyName" do
      transformer = TableOfContentsTransformer.new('2015-01-01')
      agency_representation = transformer.create_agency_representation_struct("Agency Test")
      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "agency-test"
      agency_representation.url.should == ""
    end

  end

  it ".parse_see_also collects See Also references in an array of hashes with name and slug keys" do
    xml_input = <<-XML
    <AGCY>
      <EAR>Agriculture</EAR>
      <HD>Agriculture Department</HD>
      <SEE>
        <HD SOURCE="HED">See</HD>
        <P>Agricultural Marketing Service</P>
      </SEE>
      <SEE>
        <HD SOURCE="HED">See</HD>
        <P>Food and Nutrition Service</P>
      </SEE>
      <SEE>
        <HD SOURCE="HED">See</HD>
        <P>National Institute of Food and Agriculture</P>
      </SEE>
      <CAT>
        <HD>RULES</HD>
        <DOCENT>
          <DOC>Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses,</DOC>
          <PGS>17156-17220</PGS>
          <FRDOCBP D="64" T="31MRR2.sgm">2015-06280</FRDOCBP>
        </DOCENT>
      </CAT>
    </AGCY>
    XML
    see_also_nodes = Nokogiri::XML(xml_input).css('SEE')
    transformer = TableOfContentsTransformer.new('2015-01-01')
    transformer.parse_see_also(see_also_nodes).size == 3
    transformer.parse_see_also(see_also_nodes).should == [{:name=>"Agricultural Marketing Service", :slug=>"agricultural-marketing-service"}, {:name=>"Food and Nutrition Service", :slug=>"food-and-nutrition-service"}, {:name=>"National Institute of Food and Agriculture", :slug=>"national-institute-of-food-and-agriculture"}]
  end

  it "assigns category names" do
    # TODO

    # xml_input = <<-XML
    #   <CAT>
    #     <HD>PROPOSED RULES</HD>
    #     <SJ>Increased Assessment Rates:</SJ>
    #     <SJDENT>
    #       <SJDOC>Grapes Grown in a Designated Area of Southeastern California,</SJDOC>
    #       <PGS>16998-17000</PGS>
    #       <FRDOCBP D="2" T="31MRP1.sgm">2015-07370</FRDOCBP>
    #     </SJDENT>
    #   </CAT>
    # XML
    # cat_node = Nokogiri::XML(xml_input).at_css('CAT')
    # transformer = TableOfContentsTransformer.new('2015-01-01')
    # transformer.parse_category
  end

  describe "Matching subject_1" do
    it "processes <DOCENT> properly" do
      xml_input =  <<-XML
      <CNTNTS>
        <AGCY>
          <CAT>
            <HD>RULES</HD>
            <DOCENT>
              <DOC>Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses,</DOC>
              <PGS>17156-17220</PGS>
              <FRDOCBP D="64" T="31MRR2.sgm">2015-06280</FRDOCBP>
            </DOCENT>
          </CAT>
        </AGCY>
      </CNTNTS>
      XML

      TableOfContentsTransformer.new('2015-01-01').build_table_of_contents_hash(xml_input).should == {}
    end
  end

  describe "Matching subject_2" do
      it "returns two subjects when X"
      it "returns two subjects when empty third node"
  end
  describe "Matchins subject_3" do
      it "returns a third subject when subsjdoc present"
  end
  describe  "Generates document numbers" do
      it "processes a single document correctly"
      it "processes multiple documents correctly"
  end

end

require 'spec_helper'

describe TableOfContentsTransformer do
attr_reader :transformer

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

  def process(xml)
    @nokogiri_doc = Nokogiri::XML(xml).css('CNTNTS')
  end

  # LET syntax probably does not exist.  let(:transformer) { TableOfContentsTransformer.new('2015-01-01') }
  before(:each) do
    @transformer = TableOfContentsTransformer.new('2015-01-01')
  end

  it "#parse_see_also collects See Also references in an array of hashes with name and slug keys" do
    process(<<-XML)
      <CNTNTS>
        <AGCY>
          <HD>Agricultural Marketing Service</HD>
          <SEE>
            <HD SOURCE="HED">See</HD>
            <P>Agricultural Marketing Service</P>
          </SEE>
          <SEE>
            <HD SOURCE="HED">See</HD>
            <P>Food and Nutrition Service</P>
          </SEE>
        </AGCY>
      </CNTNTS>
    XML
    expected =
      {
        agencies:
          [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              url: '',
              see_also: [
                {
                  name: 'Agricultural Marketing Service',
                  slug: 'agricultural-marketing-service'
                },
                {
                  name: 'Food and Nutrition Service',
                  slug: 'food-and-nutrition-service'
                },
                {
                  name: 'National Institute of Food and Agriculture',
                  slug: 'national-institute-of-food-and-agriculture'
                },
              ],
              document_categories: []
            }
          ]
      }

    expected2 = {:agencies=>[
      {:name=>"See", :slug=>"see", :url=>"", :see_also=>[{:name=>"Agricultural Marketing Service", :slug=>"agricultural-marketing-service"}, {:name=>"Food and Nutrition Service", :slug=>"food-and-nutrition-service"}], :document_categories=>[]}]}


    # see_also_nodes = Nokogiri::XML(xml_input).css('SEE')
    # transformer = TableOfContentsTransformer.new('2015-01-01')
    #We'll call build TOC hash in each test
    # transformer.parse_see_also(see_also_nodes).size.should == 3
    # transformer.parse_see_also(see_also_nodes).should == [{:name=>"Agricultural Marketing Service", :slug=>"agricultural-marketing-service"}, {:name=>"Food and Nutrition Service", :slug=>"food-and-nutrition-service"}, {:name=>"National Institute of Food and Agriculture", :slug=>"national-institute-of-food-and-agriculture"}]

    transformer.build_table_of_contents_hash(@nokogiri_doc).should == expected
  end

  it "Identifies category type based on first <HD>" do
    xml_input = <<-XML
      <CAT>
        <HD>PROPOSED RULES</HD>
        <SJ>Increased Assessment Rates:</SJ>
        <SJDENT>
          <SJDOC>Grapes Grown in a Designated Area of Southeastern California,</SJDOC>
          <PGS>16998-17000</PGS>
          <FRDOCBP D="2" T="31MRP1.sgm">2015-07370</FRDOCBP>
        </SJDENT>
      </CAT>
    XML
    cat_nodes = Nokogiri::XML(xml_input).css('CAT')
    transformer = TableOfContentsTransformer.new('2015-01-01')

    transformer.parse_category(cat_nodes).first["name"].should == "PROPOSED RULES"
  end

  describe "Matching subject_1" do
    it "Identifies subject_1 for <DOCENT> properly" do
      xml_input =  <<-XML
      <XML>
        <CAT>
          <HD>PROPOSED RULES</HD>
          <SJ>Increased Assessment Rates:</SJ>
          <SJDENT>
            <SJDOC>Grapes Grown in a Designated Area of Southeastern California,</SJDOC>
            <PGS>16998-17000</PGS>
            <FRDOCBP D="2" T="31MRP1.sgm">2015-07370</FRDOCBP>
          </SJDENT>
        </CAT>
        <CAT>
          <HD>RULES</HD>
          <DOCENT>
            <DOC>Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses,</DOC>
            <PGS>17156-17220</PGS>
            <FRDOCBP D="64" T="31MRR2.sgm">2015-06280</FRDOCBP>
          </DOCENT>
        </CAT>
      </XML>
      XML
      cat_nodes = Nokogiri::XML(xml_input).css('CAT')
      TableOfContentsTransformer.new('2015-01-01').build_table_of_contents_hash(xml_input)
      transformer = TableOfContentsTransformer.new('2015-01-01')
      # transformer.parse_category(cat_nodes).first[:documents].first.subject_1.should == "Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses,"
      transformer.parse_category(cat_nodes).should == "Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses,"
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

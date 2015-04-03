require 'spec_helper'

describe TableOfContentsTransformer do
attr_reader :transformer

before(:each) do
  @transformer = TableOfContentsTransformer.new('2015-01-01')
end


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

  def make_nokogiri_doc(xml)
    @nokogiri_doc = Nokogiri::XML(xml).css('CNTNTS')
  end

  before(:each) do
    @transformer = TableOfContentsTransformer.new('2015-01-01')
  end

  it "#parse_see_also collects See Also references in an array of hashes with name and slug keys" do

    make_nokogiri_doc(<<-XML)
      <CNTNTS>
        <AGCY>
          <HD>Agriculture Department</HD>
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
                }
              ],
              document_categories: []
            }
          ]
      }

    transformer.build_table_of_contents_hash(@nokogiri_doc).should == expected
  end

  it "Identifies category type based on first <HD>" do

    make_nokogiri_doc(<<-XML)
      <CNTNTS>
        <AGCY>
          <HD>Agriculture Department</HD>
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
              document_categories: []
            }
          ]
      }
    transformer.build_table_of_contents_hash(@nokogiri_doc).should == expected
  end

  describe "Matching subject_1" do

    it "Identifies subject_1 for <DOCENT> properly" do
      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>RULES</HD>
              <DOCENT>
                <DOC>Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses,</DOC>
              </DOCENT>
            </CAT>
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
                document_categories: [
                  {
                    name: "RULES",
                    documents: [
                      {
                        subject_1: 'Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses,',
                        document_numbers: []
                      }
                    ]
                  }
                ]
              }
            ]
        }

      transformer.build_table_of_contents_hash(@nokogiri_doc).should == expected
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

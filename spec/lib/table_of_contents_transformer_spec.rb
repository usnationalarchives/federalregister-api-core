require 'spec_helper'

describe TableOfContentsTransformer do
attr_reader :transformer

  before(:each) do
    @transformer = XmlTableOfContentsTransformer.new('2015-01-01')
  end

  def make_nokogiri_doc(xml)
    @nokogiri_doc = Nokogiri::XML(xml).css('CNTNTS')
  end

  describe 'Agency-lookup and cross-referencing' do
    it "AgencyName matches an existing Agency" do
      agency = Agency.create(name: "Test Agency", slug: "test-agency", url: "https://wwww.example.com/agencies/test-slug")
      agency.agency_names << AgencyName.create(name: "Agency Test")
      agency_representation = transformer.create_agency_representation("Agency Test")

      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "agency-test"
      agency_representation.url.should == "https://wwww.example.com/agencies/test-slug"
    end

    it "Provided agency name matches AgencyName but no matching Agency" do
      AgencyName.create(name: "Agency Test")
      agency_representation = transformer.create_agency_representation("Agency Test")

      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "agency-test"
      agency_representation.url.should == ""
    end

    it "Provided agency does not match any AgencyName" do
      agency_representation = transformer.create_agency_representation("Agency Test")

      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "agency-test"
      agency_representation.url.should == ""
    end
  end

  it "Creates multiple 'See Also' hashes" do

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

    transformer.build_table_of_contents(@nokogiri_doc).should == expected
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
    transformer.build_table_of_contents(@nokogiri_doc).should == expected
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
                    type: "Rule",
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

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end
  end

  describe "Matching subject_2" do
    it "Identifies two subjects when <SJ> followed by <SUBSJ> and missing <SUBSJDOC> value" do

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>NOTICES</HD>
              <SJ>Fisheries of the Exclusive Economic Zone off Alaska:</SJ>
              <SUBSJ>Applications for Exempted Fishing Permits,</SUBSJ>
              <SSJDENT>
                <SUBSJDOC/>
              </SSJDENT>
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
                    type: "Notice",
                    documents: [
                      {
                        subject_1: 'Fisheries of the Exclusive Economic Zone off Alaska:',
                        subject_2: 'Applications for Exempted Fishing Permits,',
                        document_numbers: []
                      }
                    ]
                  }
                ]
              }
            ]
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected

    end

    it "Identifies two subjects: <SJ> followed by sibling <SJDENT> and child <SJDOC>" do

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>NOTICES</HD>
              <SJ>Atlantic Highly Migratory Species:</SJ>
              <SJDENT>
                <SJDOC>Atlantic Shark Management Measures; Research Fishery; Meeting,</SJDOC>
              </SJDENT>
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
                    type: "Notice",
                    documents: [
                      {
                        subject_1: 'Atlantic Highly Migratory Species:',
                        subject_2: 'Atlantic Shark Management Measures; Research Fishery; Meeting,',
                        document_numbers: []
                      }
                    ]
                  }
                ]
              }
            ]
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end

  end

  describe "Matching subject_3" do

    it "Identifies subject_3 when <SJ>, sibling <SUBSJ>, sibling <SSJDENT>, child <SUBSJDOC>" do

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>PROPOSED RULES</HD>
              <SJ>Air Quality State Implementation Plans;  Approvals and Promulgations:</SJ>
              <SUBSJ>West Virginia; Charleston Nonattainment Area to Attainment for the 1997 Annual and 2006 24-Hour Fine Particulate Matter Standard</SUBSJ>
              <SSJDENT>
                <SUBSJDOC>West Virginia; Charleston,</SUBSJDOC>
              </SSJDENT>
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
                    type: "Proposed Rule",
                    documents: [
                      {
                        subject_1: 'Air Quality State Implementation Plans;  Approvals and Promulgations:',
                        subject_2: 'West Virginia; Charleston Nonattainment Area to Attainment for the 1997 Annual and 2006 24-Hour Fine Particulate Matter Standard',
                        subject_3: 'West Virginia; Charleston,',
                        document_numbers: []
                      }
                    ]
                  }
                ]
              }
            ]
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
      end

  end

  describe  "Generates document numbers" do
    it "Adds a single document from <FRDOCBP>" do

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>PROPOSED RULES</HD>
              <SJ>Increased Assessment Rates:</SJ>
              <SJDENT>
                <SJDOC>Grapes Grown in a Designated Area of Southeastern California,</SJDOC>
                <FRDOCBP D="2" T="31MRP1.sgm">2015-07370</FRDOCBP>
              </SJDENT>
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
                    type: "Proposed Rule",
                    documents: [
                      {
                        subject_1: 'Increased Assessment Rates:',
                        subject_2: 'Grapes Grown in a Designated Area of Southeastern California,',
                        document_numbers: ['2015-07370']
                      }
                    ]
                  }
                ]
              }
            ]
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected

    end

    it "processes multiple documents correctly" do

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>PROPOSED RULES</HD>
              <SJ>Increased Assessment Rates:</SJ>
              <SJDENT>
                <SJDOC>Grapes Grown in a Designated Area of Southeastern California,</SJDOC>
                  <FRDOCBP D="3" T="31MRP1.sgm">2015-07172</FRDOCBP>
                  <FRDOCBP D="2" T="31MRP1.sgm">2015-07280</FRDOCBP>
              </SJDENT>
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
                    type: "Proposed Rule",
                    documents: [
                      {
                        subject_1: 'Increased Assessment Rates:',
                        subject_2: 'Grapes Grown in a Designated Area of Southeastern California,',
                        document_numbers: ['2015-07172', '2015-07280']
                      }
                    ]
                  }
                ]
              }
            ]
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end
  end

end

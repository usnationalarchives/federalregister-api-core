require 'spec_helper'

describe XmlTableOfContentsTransformer do
attr_reader :transformer

  before(:each) do
    fake_issue = double(:issue)
    allow(fake_issue).to receive(:toc_note_active) { false }
    allow(fake_issue).to receive(:publication_date) { Date.parse('2015-01-01') }
    Issue.stub(:find_by).and_return(fake_issue)
    @transformer = XmlTableOfContentsTransformer.new('2015-01-01')
    allow(@transformer).to receive(:republication_substitutions).and_return({'2015-00001' => 'R1-2015-00001'})
    ElasticsearchIndexer.stub(:handle_entry_changes)
  end

  def make_nokogiri_doc(xml)
    @nokogiri_doc = Nokogiri::XML(xml).css('CNTNTS')
  end

  describe 'Agency-lookup and cross-referencing' do
    it "AgencyName matches an existing Agency" do
      agency = Agency.create(name: "Test Agency", slug: "test-agency")
      agency.agency_names <<  AgencyName.create(name: "Agency Test")
      agency_representation = transformer.create_agency_representation("Agency Test")

      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "test-agency"
    end

    it "Provided agency name matches AgencyName but there is no matching Agency" do
      AgencyName.create(name: "Agency Test")
      agency_representation = transformer.create_agency_representation("Agency Test")

      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == ""
    end

    it "Provided agency does not match any AgencyName" do
      agency_representation = transformer.create_agency_representation("Agency Test")

      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == ""
    end

    it "Provided agency has a extra whitespace" do
      agency = Agency.create(name: "Test Agency", slug: "test-agency")
      agency.agency_names <<  AgencyName.create(name: "Agency Test")
      agency_representation = transformer.create_agency_representation(" Agency Test")

      agency_representation.name.should == "Agency Test"
      agency_representation.slug.should == "test-agency"
    end
  end

  it "Creates multiple 'See Also' hashes" do
    agency1 = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
    agency1.agency_names << AgencyName.create(name: "Agriculture Department")
    agency2 = Agency.create(name: "Agricultural Marketing Service", slug: "agricultural-marketing-service")
    agency2.agency_names << AgencyName.create(name: "Agricultural Marketing Service")
    agency3 = Agency.create(name: "Food and Nutrition Service", slug: "food-and-nutrition-service")
    agency3.agency_names << AgencyName.create(name: "Food and Nutrition Service")

    # extra whitespace added
    make_nokogiri_doc(<<-XML)
      <CNTNTS>
        <AGCY>
          <HD> Agriculture Department</HD>
          <SEE>
            <HD SOURCE="HED">See</HD>
            <P>Agricultural Marketing Service</P>
          </SEE>
          <SEE>
            <HD SOURCE="HED">See</HD>
            <P> Food and Nutrition Service</P>
          </SEE>
        </AGCY>
      </CNTNTS>
    XML

    expected =
      {
        agencies: [
          {
            name: 'Agriculture Department',
            slug: 'agriculture-department',
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
        ],
        meta: {
          publication_date: '2015-01-01'
        }
      }

    transformer.build_table_of_contents(@nokogiri_doc).should == expected
  end

  it "Identifies category type based on first <HD>" do
    agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
    agency.agency_names << AgencyName.create(name: "Agriculture Department")

    make_nokogiri_doc(<<-XML)
      <CNTNTS>
        <AGCY>
          <HD>Agriculture Department</HD>
        </AGCY>
      </CNTNTS>
    XML

    expected =
      {
        agencies: [
          {
            name: 'Agriculture Department',
            slug: 'agriculture-department',
            document_categories: []
          }
        ],
        meta: {
          publication_date: '2015-01-01'
        }
      }
    transformer.build_table_of_contents(@nokogiri_doc).should == expected
  end

  describe "Matching subject_1" do

    it "Identifies subject_1 for <DOCENT> properly" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>RULES</HD>
              <DOCENT>
                <DOC>Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses, </DOC>
              </DOCENT>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies:[
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "Rule",
                  documents: [
                    {
                      subject_1: 'Resource Agency Hearings and Alternatives Development Procedures in Hydropower Licenses',
                      document_numbers: []
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end
  end

  describe "Matching subject_2" do
    it "Identifies two subjects when <SJ> followed by <SUBSJ> and missing <SUBSJDOC> value" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>NOTICES</HD>
              <SJ>Fisheries of the Exclusive Economic Zone off Alaska:</SJ>
              <SUBSJ>Applications for Exempted Fishing Permits, </SUBSJ>
              <SSJDENT>
                <SUBSJDOC/>
              </SSJDENT>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "Notice",
                  documents: [
                    {
                      subject_1: 'Fisheries of the Exclusive Economic Zone off Alaska:',
                      subject_2: 'Applications for Exempted Fishing Permits',
                      document_numbers: []
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected

    end

    it "Identifies handles <SJDENT> without a preceding <SJ> node" do
      agency = Agency.create(name: "Forest Service", slug: "forest-service")
      agency.agency_names << AgencyName.create(name: "Forest Service")

      # see https://www.govinfo.gov/bulkdata/FR/2015/03/FR-2015-03-27.xml
      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <EAR>Forest</EAR>
            <HD>Forest Service</HD>
            <CAT>
              <HD>NOTICES</HD>
              <SJDENT>
                <SJDOC>Smoky Canyon Mine, Panels F and G Lease and Mine Plan Modification Project, Caribou County, ID, </SJDOC>
                <PGS>16422-16424</PGS>
                <FRDOCBP D="2" T="27MRN1.sgm">2015-07012</FRDOCBP>
              </SJDENT>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Forest Service',
              slug: 'forest-service',
              document_categories: [
                {
                  type: "Notice",
                  documents: [
                    {
                      subject_1: '',
                      subject_2: 'Smoky Canyon Mine, Panels F and G Lease and Mine Plan Modification Project, Caribou County, ID',
                      document_numbers: ['2015-07012']
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end

    it "Identifies two subjects: <SJ> followed by sibling <SJDENT> and child <SJDOC>" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

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
          agencies: [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "Notice",
                  documents: [
                    {
                      subject_1: 'Atlantic Highly Migratory Species:',
                      subject_2: 'Atlantic Shark Management Measures; Research Fishery; Meeting',
                      document_numbers: []
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end

  end

  describe "Matching subject_3" do
    it "Identifies subject_3 when <SJ>, sibling <SUBSJ>, sibling <SSJDENT>, child <SUBSJDOC>" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>PROPOSED RULES</HD>
              <SJ>Air Quality State Implementation Plans;  Approvals and Promulgations:</SJ>
              <SUBSJ>West Virginia; Charleston Nonattainment Area to Attainment for the 1997 Annual and 2006 24-Hour Fine Particulate Matter Standard</SUBSJ>
              <SSJDENT>
                <SUBSJDOC>West Virginia; Charleston, </SUBSJDOC>
              </SSJDENT>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "Proposed Rule",
                  documents: [
                    {
                      subject_1: 'Air Quality State Implementation Plans;  Approvals and Promulgations:',
                      subject_2: 'West Virginia; Charleston Nonattainment Area to Attainment for the 1997 Annual and 2006 24-Hour Fine Particulate Matter Standard',
                      subject_3: 'West Virginia; Charleston',
                      document_numbers: []
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
      end

  end

  describe  "Generates document numbers" do
    it "Adds a single document from <FRDOCBP>" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>PROPOSED RULES</HD>
              <SJ>Increased Assessment Rates:</SJ>
              <SJDENT>
                <SJDOC>Grapes Grown in a Designated Area of Southeastern California, </SJDOC>
                <FRDOCBP D="2" T="31MRP1.sgm">2015-07370</FRDOCBP>
              </SJDENT>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "Proposed Rule",
                  documents: [
                    {
                      subject_1: 'Increased Assessment Rates:',
                      subject_2: 'Grapes Grown in a Designated Area of Southeastern California',
                      document_numbers: ['2015-07370']
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end

    it "adds the requisite R1 or R2 prefix if republications are detected.  Currently, the plant appears to be dropping the R1/R2 prefixes from the XML" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>PROPOSED RULES</HD>
              <SJ>Increased Assessment Rates:</SJ>
              <SJDENT>
                <SJDOC>Grapes Grown in a Designated Area of Southeastern California, </SJDOC>
                <FRDOCBP D="2" T="31MRP1.sgm">2015-00001</FRDOCBP>
              </SJDENT>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "Proposed Rule",
                  documents: [
                    {
                      subject_1: 'Increased Assessment Rates:',
                      subject_2: 'Grapes Grown in a Designated Area of Southeastern California',
                      document_numbers: ['R1-2015-00001']
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end

    it "processes multiple documents correctly" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>PROPOSED RULES</HD>
              <SJ>Increased Assessment Rates:</SJ>
              <SJDENT>
                <SJDOC>Grapes Grown in a Designated Area of Southeastern California, </SJDOC>
                  <FRDOCBP D="3" T="31MRP1.sgm">2015-07172</FRDOCBP>
                  <FRDOCBP D="2" T="31MRP1.sgm">2015-07280</FRDOCBP>
              </SJDENT>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "Proposed Rule",
                  documents: [
                    {
                      subject_1: 'Increased Assessment Rates:',
                      subject_2: 'Grapes Grown in a Designated Area of Southeastern California',
                      document_numbers: ['2015-07172', '2015-07280']
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end
  end

  describe  "Handles unknown document types" do
    it "Adds unknown document types to the JSON>" do
      agency = Agency.create(name: "Agriculture Department", slug: "agriculture-department")
      agency.agency_names << AgencyName.create(name: "Agriculture Department")

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Agriculture Department</HD>
            <CAT>
              <HD>TEST DOCUMENT TYPE</HD>
            </CAT>
          </AGCY>
        </CNTNTS>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Agriculture Department',
              slug: 'agriculture-department',
              document_categories: [
                {
                  type: "TEST DOCUMENT TYPE",
                  documents: [
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected

    end

    it "Adds presidential documents with unknown sub-types to the JSON" do

      make_nokogiri_doc(<<-XML)
        <CNTNTS>
          <AGCY>
            <HD>Presidential Documents</HD>
            <CAT>
              <HD>TEST SUBTYPES</HD>
              <SJ>Special Observances:</SJ>
              <SJDENT>
                <SJDOC>American Red Cross Month</SJDOC>
                <PGS>11843-11846</PGS>
                <FRDOCBP D="3" T="04MRD0.sgm">2015-04513</FRDOCBP>
              </SJDENT>
            </CAT>
          </AGCY>
      XML

      expected =
        {
          agencies: [
            {
              name: 'Presidential Documents',
              slug: '',
              document_categories: [
                {
                  type: "TEST SUBTYPES",
                  documents: [
                    {
                      subject_1: 'Special Observances:',
                      subject_2: 'American Red Cross Month',
                      document_numbers: ['2015-04513']
                    }
                  ]
                }
              ]
            }
          ],
          meta: {
            publication_date: '2015-01-01'
          }
        }

      transformer.build_table_of_contents(@nokogiri_doc).should == expected
    end
  end

end

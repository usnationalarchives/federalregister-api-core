require 'spec_helper'

describe TableOfContentsTransformer do

  describe 'Special Filing' do

    it "correctly renders documents without agencies but with agency names" do
      publication_date = '2019-05-06'
      issue = PublicInspectionIssue.new(publication_date: '2019-05-06', published_at: Date.current)
      issue.save!

      doc_1 = PublicInspectionDocument.new(
        document_number:  '2019-09500',
        publication_date: '2019-05-06',
        special_filing:   true,
        agency_names:     [AgencyName.new(name: 'Agency 1'), AgencyName.new(name: 'Agency 2')]
      )
      doc_2 = PublicInspectionDocument.new(
        document_number:  '2019-09501',
        publication_date: '2019-05-06',
        special_filing:   true,
        agency_names:     [AgencyName.new(name: 'Agency 1')]
      )
      transformer = TableOfContentsTransformer::PublicInspection::SpecialFiling.new('2019-05-06')
      transformer.stub(:entries_without_agencies).and_return([doc_1, doc_2])

      result = transformer.table_of_contents

      result.should == {
        "agencies": [
            {
              "name": "Agency 1",
              "slug": "agency-1",
              "document_categories": [
                {
                  "type": "",
                  "documents": [
                      {
                          "subject_1": "",
                          "document_numbers": [
                              "2019-09500"
                          ]
                      },
                      {
                          "subject_1": "",
                          "document_numbers": [
                              "2019-09501"
                          ]
                      }
                  ]
                }
              ]
            },
            {
              "name": "Agency 2",
              "slug": "agency-2",
              "document_categories": [
                {
                  "type": "",
                  "documents": [
                      {
                          "subject_1": "",
                          "document_numbers": [
                              "2019-09500"
                          ]
                      },
                  ]
                }
              ]
            },
          ]
      }
    end

    it "renders a document with no agency names under 'Other Documents'" do
      publication_date = '2019-05-06'
      issue = PublicInspectionIssue.new(publication_date: '2019-05-06', published_at: Date.current)
      issue.save!

      doc_1 = PublicInspectionDocument.new(
        document_number:  '2019-09500',
        publication_date: '2019-05-06',
        special_filing:   true,
        agency_names:     []
      )
      transformer = TableOfContentsTransformer::PublicInspection::SpecialFiling.new('2019-05-06')
      transformer.stub(:entries_without_agencies).and_return([doc_1])

      result = transformer.table_of_contents

      result.should == {
        :agencies => [
          {
            :name => "Other Documents",
            :slug => "other-documents",
            :document_categories => [
              {
                :type => "",
                :documents => [
                  {
                    :subject_1 => "",
                    :document_numbers => ["2019-09500"]
                  }
                ]
              }
            ]
          }
        ]
      }
    end

  end

end

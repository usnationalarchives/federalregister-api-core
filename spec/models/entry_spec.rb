=begin Schema Information

 Table name: entries

  id                           :integer(4)      not null, primary key
  title                        :text
  abstract                     :text
  contact                      :text
  dates                        :text
  action                       :text
  type                         :string(255)
  link                         :string(255)
  genre                        :string(255)
  part_name                    :string(255)
  citation                     :string(255)
  granule_class                :string(255)
  document_number              :string(255)
  toc_subject                  :string(255)
  toc_doc                      :string(255)
  length                       :integer(4)
  start_page                   :integer(4)
  end_page                     :integer(4)
  publication_date             :date
  places_determined_at         :datetime
  created_at                   :datetime
  updated_at                   :datetime
  slug                         :text
  delta                        :boolean(1)      default(TRUE), not null
  source_text_url              :string(255)
  regulationsdotgov_id         :string(255)
  comment_url                  :string(255)
  checked_regulationsdotgov_at :datetime
  volume                       :integer(4)
  full_xml_updated_at          :datetime
  regulation_id_number         :string(255)
  citing_entries_count         :integer(4)      default(0)
  document_file_path           :string(255)
  full_text_updated_at         :datetime
  cfr_title                    :string(255)
  cfr_part                     :string(255)
  curated_title                :string(255)
  curated_abstract             :string(500)
  lede_photo_id                :integer(4)
  lede_photo_candidates        :text

=end Schema Information

require 'spec_helper'

describe Entry do
  describe 'slug' do
    it "should downcase" do
      Entry.new(:title => "Meeting").slug.should == 'meeting'
    end
    
    it "should convert non-alphanumeric characters to dashes" do
      Entry.new(:title => "Proposed Rule").slug.should == 'proposed-rule'
    end
    
    it "should omit dashes at beginning and end" do
      Entry.new(:title => "[Amended]").slug.should == 'amended'
    end
    
    it "should convert ampersands to 'and'" do
      Entry.new(:title => "Foo & Bar").slug.should == 'foo-and-bar'
    end
    
    it "should limit the length to 100 characters" do
      Entry.new(:title => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt unt labore et dolore magna aliqua.").slug.should ==
        'lorem-ipsum-dolor-sit-amet-consectetur-adipisicing-elit-sed-do-eiusmod-tempor-incididunt-unt-labore'
    end
    
    it "should not truncate in the middle of a word" do
      Entry.new(:title => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed unt eiusmod tempor incididunt labore cumin").slug.should == 'lorem-ipsum-dolor-sit-amet-consectetur-adipisicing-elit-sed-unt-eiusmod-tempor-incididunt-labore'
    end
    
  end
end

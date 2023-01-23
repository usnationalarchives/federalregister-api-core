require "spec_helper"

describe XmlCorrection do

  def copy_fixture_xml_to_data_dir!(date)
    path_manager = FileSystemPathManager.new(date)
    FileUtils.mkdir_p path_manager.document_issue_xml_dir
    `cp spec/fixtures/2016-04-15.xml #{path_manager.document_issue_xml_path}` #ie refresh the file so subsequent runs of this test start with a fresh copy of the xml file and the patch can be applied
  end

  def clean_up_patch_directory!(date)
    path_manager = FileSystemPathManager.new(date)
    `rm -r #{path_manager.document_issue_xml_corrections_path}`
  end

  it "does not fail if it's called on an issue with no patches" do
    date = Date.new(2050,1,1)
    path_manager = FileSystemPathManager.new(date)
    copy_fixture_xml_to_data_dir!(date)
    xml_correction = XmlCorrection.new(date)

    expect{ xml_correction.apply }.not_to raise_error
  end

  it "#apply can apply an actual patch" do
    date = Date.new(2016,4,15)
    path_manager = FileSystemPathManager.new(date)
    copy_fixture_xml_to_data_dir!(date)
    xml_correction = XmlCorrection.new(date)

    expect{ xml_correction.apply }.not_to raise_error
  end

  it "PatchCreator creates sequential patches successfully" do
    date = Date.new(2030,1,1)
    path_manager = FileSystemPathManager.new(date)
    entry = Factory.create(:entry, document_number: '2016-08449', publication_date: date)
    allow($stdin).to receive(:gets).and_return('w') # ie simulate making no edits #SOMEDAY TODO: It might be nice if we tested real patch content changes

    # Apply Patch 1
    PatchCreator.new(
      document_number: entry.document_number,
      publication_date: entry.publication_date,
      description: "Test Patch 1"
    ).perform
    expect{ XmlCorrection.new(date).apply }.not_to raise_error

    # Apply Patch 2
    expect(File.exists?("#{path_manager.document_issue_xml_corrections_path}/01/#{entry.document_number}.patch")).to eq(true)
    PatchCreator.new(
      document_number: entry.document_number,
      publication_date: entry.publication_date,
      description: "Test Patch 2"
    ).perform
    copy_fixture_xml_to_data_dir!(date)
    expect{ XmlCorrection.new(date).apply }.not_to raise_error
    expect(File.exists?("#{path_manager.document_issue_xml_corrections_path}/02/#{entry.document_number}.patch")).to eq(true)
    clean_up_patch_directory!(date)
  end

end

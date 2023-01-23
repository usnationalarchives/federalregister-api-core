class PatchCreator
  extend Memoist

  def initialize(document_number:,publication_date:, description:, reference: nil)
    entry_attributes = {document_number: document_number}.tap do |hsh|
      if publication_date
        hsh.merge!(publication_date: publication_date)
      end
    end
    @description = description
    @entry = Entry.find_by!(entry_attributes)
    @publication_date = publication_date.is_a?(Date) ? publication_date : Date.parse(publication_date)
  end

  def perform
    FileUtils.mkdir_p(issue_corrections_path)
    puts "Creating xml corrections directory at #{patch_path}..."
    FileUtils.mkdir_p(patch_path)
    create_meta_yml_file!
    begin
      create_temp_xml_file!
      wait_for_user_to_modify_temp_xml_file
      create_patch_file_using_diff_utility!
    ensure
      cleanup_temp_xml_file!
    end
  end

  private

  attr_reader :reference, :description, :entry, :publication_date

  def wait_for_user_to_modify_temp_xml_file
    desired_value = "w"
    loop do
      user_input = $stdin.gets.chomp
      break if user_input == desired_value
      puts "You entered: #{user_input}"
    end
  end

  def patch_number_string
    last_patch = Dir.entries(issue_corrections_path).reject{|x| ['.','..'].include? x}.sort.last
    if last_patch
      patch_number = (last_patch.to_i + 1)
      sprintf('%02d', patch_number) #Add leading zero
    else
      "01"
    end
  end
  memoize :patch_number_string

  def patch_path
    File.join(issue_corrections_path, patch_number_string)
  end

  def issue_corrections_path
    path_manager.document_issue_xml_corrections_path
  end

  def document_issue_xml_path
    path_manager.document_issue_xml_path
  end

  def path_manager
    FileSystemPathManager.new(entry.publication_date)
  end

  def create_meta_yml_file!
    puts "Creating meta.yml file..."
    File.write("#{patch_path}/meta.yml", metayml_file_content)
  end

  def metayml_file_content
<<-YAML
reference: #{reference}
description: #{description}
YAML
  end

  def create_temp_xml_file!
    `cp #{document_issue_xml_path} #{temp_xml_file}`
    puts "A copy of the #{publication_date.to_s(:iso)} XML has been placed at #{temp_xml_file}.  Please edit accordingly and press 'w' when finished editing it to continue the patching process."
  end

  def cleanup_temp_xml_file!
    `rm -f #{temp_xml_file}`
  end

  def temp_xml_file
    "tmp/#{publication_date.to_s(:iso)}_modified_tmp.xml"
  end

  def create_patch_file_using_diff_utility!
    puts "Creating the patch file using the diff utility..."
    `diff -u #{document_issue_xml_path} #{temp_xml_file} > #{patch_path}/#{entry.document_number}.patch`
  end

end

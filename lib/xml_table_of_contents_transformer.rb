require 'ostruct'

class XmlTableOfContentsTransformer
  attr_reader :date, :toc_hash

  def initialize(doc_date)
    @date = doc_date.to_date
    @toc_hash = {agencies:[] }
  end

  def self.perform(date)
    toc_stub = new(date)
    toc_stub.process
    toc_stub.save_json_file
  end

  def process
    xml_input_file = File.open(input_location)
    nokogiri_doc = Nokogiri::XML(xml_input_file).css('CNTNTS')
    xml_input_file.close
    build_table_of_contents_hash(nokogiri_doc)
  end

  def build_table_of_contents_hash(nokogiri_doc)
    nokogiri_doc.css('AGCY').each do |agcy_node|
      agency_struct = create_agency_representation_struct(agcy_node.css('HD').first.text)
      toc_hash[:agencies].push({
        name: agency_struct.name,
        slug: agency_struct.slug,
        url: agency_struct.url,
        see_also: parse_see_also(agcy_node.css('SEE')),
        document_categories: parse_category(agcy_node.css('CAT'))
      }.delete_if{|k,v| v.nil?})
    end
    toc_hash
  end

  def create_agency_representation_struct(agency_name)
    agency = lookup_agency(agency_name)
    if agency
      agency_representation = OpenStruct.new(name: agency_name, slug: agency.slug, url: agency.url)
    else
      agency_representation = OpenStruct.new(name: agency_name, slug: agency_name.downcase.gsub(' ','-'), url: '' )
    end
    agency_representation
  end

  def lookup_agency(agency_name)
    agency_alias = AgencyName.find_by_name(agency_name)
    agency_alias.agency if agency_alias
  end

  def parse_see_also(see_also_nodes)
    see_also = []
    see_also_nodes.each do |see_also_node|
      agency_struct = create_agency_representation_struct(see_also_node.css('P').text)
      see_also.push({
        name: see_also_node.css('P').text,
        slug: agency_struct.slug
      })
    end
    see_also.present? ? see_also : nil
  end

  def parse_category(cat_nodes)
    cat_nodes.map do |cat_node|
      category = Category.new(cat_node)
      category.process_nodes
      {
        name: category.name,
        documents: category.documents_as_hashes
      }
    end
  end

  def save_json_file
    save_file(output_path, output_filename, toc_hash.to_json)
  end

  def save_file(path, filename, table_of_contents_hash)
    FileUtils.mkdir_p(path)
    File.open "#{path}/#{filename}", 'w' do |f|
      f.write(table_of_contents_hash)
    end
  end


class Category
  attr_reader :document, :documents, :cat_node, :name

  def initialize(cat_node)
    @cat_node = cat_node
    @documents = []
  end

  def process_nodes
    cat_node.children.each do |node|
      process_hd_node(node) if node.name == 'HD'
      process_sj_node(node) if node.name == 'SJ'
      process_subsj_node(node) if node.name == 'SUBSJ'
      process_sjdent_node(node) if node.name == "SJDENT"
      process_ssjdent_node(node) if node.name == "SSJDENT"
      process_docent_node(node) if node.name == 'DOCENT'
    end
  end

  def process_hd_node(hd_node)
    @name = hd_node.text
  end

  def process_sj_node(sj_node)
    @document = CategoryDocument.new
    document.subject_1 = sj_node.text
  end

  def process_subsj_node(subsj_node)
    document.subject_2 = subsj_node.text
  end

  def process_sjdent_node(sjdent_node)
    document.subject_2 = sjdent_node.at_css('SJDOC').text
    document.document_numbers = process_document_numbers(sjdent_node.css('FRDOCBP'))
    write_document
  end

  def process_ssjdent_node(ssjdent_node)
    subsjdoc_text = ssjdent_node.css('SUBSJDOC').text
    document.subject_3 = subsjdoc_text if subsjdoc_text.present?
    document.document_numbers = process_document_numbers(ssjdent_node.css('FRDOCBP'))
    write_document
  end

  def process_docent_node(docent_node)
    @document = CategoryDocument.new
    document.subject_1 = docent_node.at_css('DOC').text
    document.document_numbers = process_document_numbers(docent_node.css('FRDOCBP'))
    write_document
  end

  def process_document_numbers(doc_nodes)
    doc_nodes.map{ |doc_node| doc_node.text }
  end

  def write_document
    subject_1 = document.subject_1
    documents << document.dup
    document = CategoryDocument.new
    document.subject_1 = subject_1
    #TODO: Is it necessary to clear subject_2?
  end

  def documents_as_hashes
    documents.map do |document|
      {
        subject_1: document.subject_1,
        subject_2: document.subject_2,
        subject_3: document.subject_3,
        document_numbers: document.document_numbers
      }.delete_if{|k,v| v.nil?}
    end
  end

end

class CategoryDocument
  attr_accessor :subject_1, :subject_2, :subject_3, :document_numbers
end

private

def input_location
  "data/bulkdata/FR-#{date.strftime('%Y-%m-%d')}.xml"
end

def output_path
  "data/document_issues/json/#{date.to_s(:year_month)}/"
end

def output_filename
  date.strftime('%d') +'.json'
end

end
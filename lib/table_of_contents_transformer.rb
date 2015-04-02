class TableOfContentsTransformer
  attr_reader :parse_category, :parse_documents, :path_to_xml_file, :toc_hash

  def initialize(path_to_xml_file='data/xml/table_of_contents/example1.xml')
    @path_to_xml_file = path_to_xml_file
    @toc_hash = {agencies:[] }
  end

  def process
    nokogiri_doc = Nokogiri::XML(open(path_to_xml_file))
    nokogiri_doc.css('AGCY').each do |agcy_node|
      #agency = find_or_create_agency(agcy_node.css('HD').first.text)
      toc_hash[:agencies].push({
        name: agcy_node.css('HD').first.text, #agency.name,
        slug: "todo", #agency.slug,
        url: "www.TODO.com", #agency.url,
        see_also: parse_see_also(agcy_node.css('SEE')),
        document_categories: parse_category(agcy_node.css('CAT'))
      }.delete_if{|k,v| v.nil?})
    end

    save_file('brandon_test.json', toc_hash.to_json)
  end

  def find_or_create_agency(agency_name)
    if agency = Agency.find_by_name(agency_name)
      agency
    else
      Agency.create(name: agency_name, slug: agency_name.downcase.gsub('','-'))
    end
  end

  def parse_see_also(see_also_nodes)
    see_also = []
    see_also_nodes.each do |see_also_node|
      see_also.push({
        name: see_also_node.css('P').text,
        slug: "todo"
      })
    end
    see_also.present? ? see_also : nil
  end

  def parse_category(cat_nodes)
    cat_nodes.map do |cat_node|
      category = Category.new(cat_node)
      category.process_nodes
      {
        "name" => category.name,
        "documents" => category.documents
      }
    end
  end

  def save_file(filename, ruby_object)
    Dir.chdir('data/xml/table_of_contents')
    file = File.open(filename, 'w')
    file.puts(ruby_object)
    file.close
    Dir.chdir('../../..')
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
    document.subject_3 = ssjdent_node.css('SUBSJDOC').text
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

end

class CategoryDocument
  attr_accessor :subject_1, :subject_2, :subject_3, :document_numbers
end


end
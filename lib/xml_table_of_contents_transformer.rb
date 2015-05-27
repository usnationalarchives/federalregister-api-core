require 'ostruct'

class XmlTableOfContentsTransformer
  attr_reader :date, :path_manager, :table_of_contents

  def initialize(date)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @table_of_contents = {agencies:[]}
    @path_manager = FileSystemPathManager.new(@date)
  end

  def self.perform(date)
    transformer = new(date)
    transformer.process
    transformer.save
  end

  def process
    contents_node = File.open(path_manager.document_issue_xml_path) do |file|
      Nokogiri::XML(file).css('CNTNTS')
    end
    build_table_of_contents(contents_node)
  end

  def build_table_of_contents(contents_node)
    contents_node.css('AGCY').each do |agency_node|
      agency = create_agency_representation(agency_node.css('HD').first.text)
      table_of_contents[:agencies].push({
        name: agency.name,
        slug: agency.slug,
        url: agency.url,
        see_also: parse_see_also(agency_node.css('SEE')),
        document_categories: parse_category(agency_node.css('CAT'))
      }.delete_if{|k,v| v.nil?})
    end
    table_of_contents
  end

  def create_agency_representation(agency_name)
    agency = lookup_agency(agency_name)

    agency_representation = OpenStruct.new(
      name: agency_name,
      slug: agency_name.downcase.gsub(' ','-'),
      url: ''
    )

    agency_representation.url = agency.url if agency

    agency_representation
  end

  def lookup_agency(agency_name)
    AgencyName.find_by_name(agency_name).try(:agency)
  end

  def parse_see_also(see_also_nodes)
    see_also = []
    see_also_nodes.each do |see_also_node|
      agency_struct = create_agency_representation(see_also_node.css('P').text)
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
        type: category.name,
        documents: category.documents_as_hashes
      }
    end
  end

  def save
    FileUtils.mkdir_p(path_manager.document_issue_json_toc_dir)

    File.open path_manager.document_issue_json_toc_path, 'w' do |f|
      f.write(table_of_contents.to_json)
    end
  end


  class Category
    attr_reader :document, :documents, :cat_node, :name

    DOCUMENT_TYPE_MAPPINGS = {
      'RULES' =>                  'Rule',
      'PROPOSED RULES' =>         'Proposed Rule',
      'NOTICES' =>                'Notice',
      'CORRECT' =>                'Correction', #B.C. TODO: Verify
      'UNKNOWN' =>                'Uncategorized Document', #B.C. TODO: Verify
      'SUNSHINE' =>               'Sunshine Act Document', #B.C. TODO: Verify
      'PROCLAMATIONS' =>          'Proclamation',
      'MEMORANDUMS' =>            'Memorandum', #B.C. TODO: Verify
      'PRESIDENTIAL ORDERS' =>    'Presidential Order', #B.C. TODO: Verify
      'ADMINISTRATIVE ORDERS' =>  'Administrative Order',
      'EXECUTIVE ORDERS' =>       'Executive Order'
    }

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
      @name = document_type(hd_node.text)
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
          document_numbers: document.document_numbers.gsub(/-+/,'-')
        }.delete_if{|k,v| v.nil?}
      end
    end

    def document_type_mappings
      DOCUMENT_TYPE_MAPPINGS
    end

    class CategoryDocument
      attr_accessor :subject_1, :subject_2, :subject_3, :document_numbers
    end

    private

    def document_type(document_type_from_xml)
      if document_type_mappings[document_type_from_xml].present?
        document_type_mappings[document_type_from_xml]
      else
        error = "'#{document_type_from_xml}' is not a recognized document_type.
          See DOCUMENT_TYPE_MAPPINGS in xml_table_of_contents_transformer."
        Rails.logger.warn(error)
        Honeybadger.notify(
          :error_class   => "Unrecognized document type encountered in GPO XML",
          :error_message => error
        )
        document_type_from_xml
      end
    end

  end

end

require 'ostruct'

class XmlTableOfContentsTransformer
  extend Memoist
  attr_reader :date, :path_manager, :table_of_contents, :issue

  GPO_XML_START_DATE = Date.parse('2000-01-18')

  class MissingXMLError < StandardError; end
  class MissingXMLCntntsError < StandardError; end

  def initialize(date)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @issue = Issue.find_by(publication_date: date)
    @table_of_contents = {agencies:[]}
    @path_manager = FileSystemPathManager.new(@date)
  end

  def self.perform(date)
    transformer = new(date)
    transformer.process
    transformer.save
  end

  def process
    begin
      contents_node = File.open(path_manager.document_issue_xml_path) do |file|
        Nokogiri::XML(file).css('CNTNTS')
      end

      if contents_node.present?
        build_table_of_contents(contents_node)
      else
        Honeybadger.notify(
          :error_message   => "Missing CNTNTS node in GPO XML file",
          :parameters => {
            :date => date
          }
        )

        raise XmlTableOfContentsTransformer::MissingXMLCntntsError
      end
    rescue Errno::ENOENT => e
      if date >= GPO_XML_START_DATE
        Rails.logger.warn(e)
        Honeybadger.notify(
          :error_class   => "Missing GPO XML file",
          :error_message => e.message,
          :backtrace => e.backtrace,
          :parameters => {
            :date => date
          }
        )
      end

      raise XmlTableOfContentsTransformer::MissingXMLError
    end
  end

  def build_table_of_contents(contents_node)
    contents_node.css('AGCY').each do |agency_node|
      agency = create_agency_representation(agency_node.css('HD').first.text)
      table_of_contents[:agencies].push({
        name: agency.name,
        slug: agency.slug,
        see_also: parse_see_also(agency_node.css('SEE')),
        document_categories: parse_category(agency_node.css('CAT'))
      }.delete_if{|k,v| v.nil?})
    end
    table_of_contents[:note] = {title: issue.toc_note_title, text: issue.toc_note_text} if issue.toc_note_active
    table_of_contents
  end

  def create_agency_representation(agency_name)
    agency = lookup_agency(agency_name)

    OpenStruct.new(
      name: agency_name.strip,
      slug: agency ? agency.slug : ''
    )
  end

  def lookup_agency(text)
    agency_name = AgencyName.find_by_name(text.strip)

    unless agency_name
      Rails.logger.warn("Agency name in ToC but no record found: #{text.strip} for #{date}")
      Honeybadger.notify(
        :error_message => "Agency name in ToC but no record found",
        :parameters    => {
          :agency_name => text.strip,
          :date => date
        }
      )
    end

    agency_name.try(:agency)
  end

  def parse_see_also(see_also_nodes)
    see_also = []
    see_also_nodes.each do |see_also_node|
      agency_name = see_also_node.css('P').text
      agency = create_agency_representation(agency_name)
      see_also.push({
        name: agency.name,
        slug: agency.slug
      })
    end
    see_also.present? ? see_also : nil
  end

  def parse_category(cat_nodes)
    cat_nodes.map do |cat_node|
      category = Category.new(cat_node, republication_substitutions)
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

  private

  def republication_substitutions
    republications.each_with_object({}) do |entry, hsh|
      doc_number_sans_republication_prefix = entry.
        document_number.
        gsub("R1-","").
        gsub("R2-","")
      hsh[doc_number_sans_republication_prefix] = entry.document_number
    end
  end
  memoize :republication_substitutions

  def republications
    issue.entries.where("document_number LIKE 'R%'")
  end

  class Category
    attr_reader :document, :documents, :cat_node, :name

    DOCUMENT_TYPE_MAPPINGS = {
      'RULES' =>                  'Rule',
      'PROPOSED RULES' =>         'Proposed Rule',
      'NOTICES' =>                'Notice',
      'CORRECT' =>                'Correction',
      'UNKNOWN' =>                'Uncategorized Document',
      'SUNSHINE' =>               'Notice',
      'PROCLAMATIONS' =>          'Proclamation',
      'MEMORANDUMS' =>            'Memorandum',
      'PRESIDENTIAL ORDERS' =>    'Presidential Order',
      'ADMINISTRATIVE ORDERS' =>  'Administrative Order',
      'EXECUTIVE ORDERS' =>       'Executive Order',
    }

    # other mispelled, etc
    LEGACY_DOCUMENT_TYPE_MAPPINGS = {
      'ADMINISTRATVE ORDERS' => 'Administrative Order',
      'AMINISTRATIVE ORDERS' => 'Administrative Order',
      'EXECUTVE ORDERS' => 'Executive Order',
      'EXECECUTIVE ORDERS' => 'Executive Order',
      'NOTICE' => 'Notice',
      'NOTICES0' => 'Notice',
      'PROCLAMATION' => 'Proclamation',
    }

    def initialize(cat_node, republication_substitutions={})
      @cat_node = cat_node
      @republication_substitutions = republication_substitutions
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
      # occasionally there isn't a SJ node preceding a SJDENT node
      unless document
        @document = CategoryDocument.new
        document.subject_1 = ""
      end
      document.subject_2 = sjdent_node.at_css('SJDOC').try(:text)
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
      doc_nodes.map do |doc_node|
        number = doc_node.text.tr("–", "-")

        if republication_substitutions[number]
          republication_substitutions[number]
        else
          number
        end
      end
    end

    def write_document
      subject_1 = document.subject_1
      documents << document.dup
      document = CategoryDocument.new
      document.subject_1 = subject_1
    end

    def documents_as_hashes
      documents.map do |document|
        {
          subject_1: strip_trailing_comma(document.subject_1),
          subject_2: strip_trailing_comma(document.subject_2),
          subject_3: strip_trailing_comma(document.subject_3),
          document_numbers: document.document_numbers.map{|n| n.gsub(/-+/,'-')}
        }.delete_if{|k,v| v.nil?}
      end
    end

    def document_type_mappings
      DOCUMENT_TYPE_MAPPINGS.merge(LEGACY_DOCUMENT_TYPE_MAPPINGS)
    end

    class CategoryDocument
      attr_accessor :subject_1, :subject_2, :subject_3, :document_numbers
    end

    private

    attr_reader :republication_substitutions

    def strip_trailing_comma(text)
      if text
        text.strip.sub(/,$/, '')
      else
        nil
      end
    end

    def document_type(document_type_from_xml)
      invalid_chars = /,|:/
      clean_doc_type = document_type_from_xml.strip.gsub(invalid_chars,'')

      if document_type_mappings[clean_doc_type.upcase].present?
        document_type_mappings[clean_doc_type.upcase]
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

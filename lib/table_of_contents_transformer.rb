class TableOfContentsTransformer
  attr_reader :parse_category, :parse_documents, :path_to_xml_file, :toc_hash

  def initialize(path_to_xml_file='data/xml/table_of_contents/example4.xml')
    @path_to_xml_file = path_to_xml_file
    @toc_hash =
      toc_hash = {
        agencies: []
      }
  end

  def process
    nokogiri_doc = Nokogiri::XML(open(path_to_xml_file))
    nokogiri_doc.css('AGCY').each do |agcy_node|
      toc_hash[:agencies].push({
        name: agcy_node.css('HD').first.text,
        slug: "todo",
        url: "www.TODO.com",
        see_also: parse_see_also(agcy_node.css('SEE')),
        document_categories: parse_category(agcy_node.css('CAT'))
      })
    end

    #Logic for saving actual file
    Dir.chdir('data/xml/table_of_contents')
    file = File.open('brandon_test.json','w')
    file.puts(toc_hash.to_json)
    file.close
    Dir.chdir('../../..')
  end

  def parse_see_also(nodes)
    see_also = []
    nodes.each do |see_also_node|
      see_also.push({
        name: see_also_node.css('P').text,
        slug: "todo"
      })
    end
    see_also.present? ? see_also : nil
  end

  def parse_category(nodes)
    categories = []
    nodes.each do |cat_node|
      categories.push({
        :name => cat_node.css('HD').text,
        # :documents => parse_documents(cat_node.css('SJDENT'))
        :documents => CategoryDocumentAssembler.new(cat_node).documents_array
      })
    end
    categories
  end

  class CategoryDocumentAssembler
    attr_reader :category_node

    def initialize(category_node)
      @category_node = category_node
    end

    def sjdent_documents
      sjdent_documents = []
      category_node.css('SJDENT').each do |sjdent_node|
        sjdent_documents.push({
          subject_1: find_previous_sibling('SJ', sjdent_node).text,
          subject_2: sjdent_node.at_css('SJDOC').text,
          document_numbers: parse_document_numbers(sjdent_node.css('FRDOCBP'))
        })
      end
      sjdent_documents
    end

    def docent_documents
      category_node.css('DOCENT').map do |docent_node|
        {
          subject_1: docent_node.at_css('DOC').text,
          document_numbers: parse_document_numbers(docent_node.css('FRDOCBP'))
        }
      end
    end

    def ssjdent_documents
      category_node.css('SSJDENT').map do |ssjdent_node|
        {
          subject1: find_previous_sibling('SJ', ssjdent_node).text,
          subject2: find_previous_sibling('SUBSJ', ssjdent_node).text,
          subject3: (ssjdent_node.css('SUBSJDOC').text if ssjdent_node.css('SUBSJDOC')),
          document_numbers: parse_document_numbers(ssjdent_node.css('FRDOCBP'))
        }#.delete_if{|k,v| v.nil?}
      end
    end

    def documents_array
      sjdent_documents + ssjdent_documents + docent_documents
    end


    def find_previous_sibling(tag, node)
      result = nil

      while node != nil
        if node.name == tag
          result = node
          break
        else
          node = node.previous
        end
      end

      result
    end

    def parse_document_numbers(nodes)
      document_numbers = []
      nodes.each do |frdocbp_node|
        document_numbers.push(frdocbp_node.text)
      end
      document_numbers
    end

  end






  def agency_exists?(agency)
    #TODO Lookup in the DB
  end

  def agency_slug(agency_name)
    #TODO Lookup in the DB
  end

end
#NOTE: This parser logic was sourced from https://github.com/GSA-TTS/all_sorns

class SornXmlParser
  # Uses an XML streamer. Each method re-streams the file. Fast enough and uses no memory.

  def initialize(xml)
    @parser = Saxerator.parser(xml)
  end

  def parse_xml
    { summary: find_tag('SUM'),
      addresses: find_tag('ADD'),
      further_info: find_tag('FURINF'),
      supplementary_info: find_tag('SUPLINF'),
      system_name: get_system_name,
      system_number: get_system_number,
      security: find_section('SECURITY'),
      location: find_section('LOCATION'),
      manager: find_section('MANAGER'),
      authority: find_section('AUTHORITY'),
      purpose: find_section('PURPOSE'),
      categories_of_individuals: find_section('INDIVIDUALS'),
      categories_of_record: find_section('CATEGORIES OF RECORDS'),
      source: find_section('SOURCE'),
      routine_uses: find_section('ROUTINE'),
      storage: find_section('STORAGE'),
      retrieval: find_section('RETRIEVAL'), #Retrievability
      retention: find_section('RETENTION'),
      safeguards: find_section('SAFEGUARDS'),
      access: find_section('ACCESS'),
      contesting: find_section('CONTESTING'),
      notification: find_section('NOTIFICATION'),
      exemptions: find_section('EXEMPTIONS'),
      history: find_section('HISTORY') }
  end

  def get_system_name
    @system_name = find_section('SYSTEM NAME')
  end

  def get_system_number
    number = find_section('NUMBER')
    if number and @system_name
      parse_system_name_from_number(@system_name)
    end
  end

  def get_system_metadata
    system_descriptions = get_sections(add_p_tags: false).first.last
    system_descriptions.map do |system_description|
      OpenStruct.new(
        name: system_description,
        identifier: parse_system_name_from_number(system_description)
      )
    end
  end

  def find_tag(tag)
    tag_content = @parser.for_tag(tag).first
    return nil unless tag_content.present?

    paragraph_content = tag_content.fetch("P")

    # sometimes there is just one P in a tag
    # return it as a cleaned up string
    return cleanup_xml_element_to_string(paragraph_content) if paragraph_content.class == Saxerator::Builder::StringElement

    # usually content is an array of P content
    # clean the contents of the array
    # add p tags if needed and return a single string
    paragraph_content = paragraph_content.map { |node| cleanup_xml_element_to_string(node) }
    add_p_tags(paragraph_content).join(" ")
  end

  def find_section(header)
    # Get a named section of the PRIACT tag
    # header of 'NUMBER' will match the section with key 'System Name and Number'
    @sections ||= get_sections
    matched_header = @sections.keys.find{ |key| key.upcase.include? header }
    @sections[matched_header]
  end

  private

  def get_sections(add_p_tags: true)
    # Gather the named sections of the PRIACT tag
    sections = {}
    current_header = nil
    @parser.within('PRIACT').each do |node|
      if node.name == 'HD'
        current_header = cleanup_xml_element_to_string(node)
        sections[current_header] = []
      elsif current_header.nil?
        next
      elsif node.name == 'P'
        # Skipping a few rare FTNT, NOTE, and EXTRACT tags
        # append cleaned strings
        sections[current_header] << cleanup_xml_element_to_string(node)
      end
    end

    # discard the rare nil keys
    sections.except!(nil)
    # Change arrays of section content into paragraphs.
    if add_p_tags
      sections.transform_values! { |values| add_p_tags(values).join(" ") }
    else
      sections
    end
  end

  def cleanup_xml_element_to_string(element)
    # recursively convert hashes and array down to a string
    element = xml_hash_to_string(element) if element.class == Saxerator::Builder::HashElement
    element = xml_array_to_string(element) if element.class.in? [Array, Saxerator::Builder::ArrayElement]
    element.strip if element.class.in? [String, Saxerator::Builder::StringElement]
  end

  def xml_hash_to_string(element)
    if element.fetch('P', nil).present?
      # Grab the paragraphs out of any hashes
      cleanup_xml_element_to_string(element.fetch('P', nil))
    else
      # A very few section headers have a hash with E
      cleanup_xml_element_to_string(element.fetch('E', nil))
    end
  end

  def xml_array_to_string(element)
    # Arrays can contain hashes and arrays
    # turn all the inside elements into strings then join on spaces
    element.map do |e|
      cleanup_xml_element_to_string(e)
    end.join(" ")
  end

  def add_p_tags(content)
    if content.length > 1
      content.map{|paragraph| "<p>#{paragraph}</p>" }
    else
      content
    end
  end

  def parse_system_name_from_number(string)
    digit_regex = Regexp.new('\d')
    if string.match(digit_regex)
      precleaned = strip_known_patterns(string)
      regex_captures = collect_regex_captures(precleaned)
      if regex_captures.length > 0
        cleaned_capture(regex_captures)
      end
    end
  end

  def strip_known_patterns(system_name)
    # This regex will strip the common pattern of a "(Month DD, YYY, Federal register citation)""
    no_cfr_syst_name = system_name.gsub(/\(\w+ \d\d\, \d{4}\, \d\d FR \d{4,6}\)/, '')
    # Remove references to the HSPD-12 PIV Card policy
    return no_cfr_syst_name.gsub(/HSPD-12/, '')
  end

  def collect_regex_captures(precleaned_system_name)
    regex_captures = []
    # Looks for a variety of common system number reference patterns that are either
    # just numbers or a combination of number and agency abbreviation system numbers
    generic_match = precleaned_system_name.match(/(\w+\/)?\w+(-| |.)\d+(-\d+)?/)
    if generic_match
      regex_captures.append(generic_match[0])
    end
    regex_captures
  end

  def cleaned_capture(capture_array)
    capture_array.delete('-')
    capture_array.uniq
    if capture_array.length > 0
      capture_array.join(', ')
    end
  end
end

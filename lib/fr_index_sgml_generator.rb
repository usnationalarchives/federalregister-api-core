class FrIndexSgmlGenerator

  def initialize(year)
    @year = year
  end

  FR_INDEX_DOCUMENT_TYPE = 'PRESDOCU'
  def perform
    text = ""
    text << header

    document_type = FrIndexPresenter::DocumentType.new(
      executive_office_of_the_president,
      year,
      FR_INDEX_DOCUMENT_TYPE
    )

    document_type.groupings.group_by{|x| x.header[0] }.each do |first_letter, groupings|
      text << "<ALPHHD>#{first_letter}\n"
      groupings.each do |grouping|
        case grouping
        when FrIndexPresenter::SubjectGrouping
          text << subject_grouping_text(grouping)
        when FrIndexPresenter::DocumentGrouping
          text << document_grouping_text(grouping, 'SUBJHED')
        end
      end
    end

    text
  end


  private

  attr_reader :year

  def executive_office_of_the_president
    Agency.find_by_short_name('EOP')
  end

  def header
    <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
    SGML
  end


  def subject_grouping_text(grouping)
<<-SGML
<SUBJHED>#{CGI.escapeHTML(grouping.header)}
#{grouping.document_groupings.map{|document_grouping| document_grouping_text(document_grouping, 'SUBJECT1')}.join("\n")}
SGML
  end

  def document_grouping_text(document_grouping, tag_name)
<<-SGML
<#{tag_name}>#{CGI.escapeHTML(document_grouping.header)} (#{CGI.escapeHTML(document_grouping.parenthetical_citation)})
SGML
  end

end

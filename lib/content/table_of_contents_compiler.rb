module Content
  module TableOfContentsCompiler
    GPO_XML_START_DATE = Date.parse('2000-01-18')

    def self.perform(date)
      date = date.is_a?(String) ? Date.parse(date) : date

      if date >= GPO_XML_START_DATE
        XmlTableOfContentsTransformer.perform(date)
      else
        TableOfContentsTransformer::DocumentIssue.perform(date)
      end
    end
  end
end

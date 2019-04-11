module Content
  module TableOfContentsCompiler
    def self.perform(date)
      begin
        XmlTableOfContentsTransformer.perform(date)
      rescue XmlTableOfContentsTransformer::MissingXMLError, XmlTableOfContentsTransformer::MissingXMLCntntsError
        TableOfContentsTransformer::DocumentIssue.perform(date)
      end
    end
  end
end

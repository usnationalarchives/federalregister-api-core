module Content::EntryImporter::TextCitations
  extend Content::EntryImporter::Utils
  provides :citations

  def citations
    Citation.extract!(entry)
  end
end

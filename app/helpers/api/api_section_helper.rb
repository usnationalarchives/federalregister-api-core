module Api::ApiSectionHelper
  def highlighted_entry_hash(entry)
    {
      :document_number => entry.document_number,
      :html_url => ApiRepresentation.entry_url(entry),
      :curated_title => entry.curated_title,
      :curated_abstract => entry.curated_abstract,
      :photo => entry.lede_photo.present? ? {
        :urls => {
          :navigation => entry.lede_photo.photo.url(:navigation),
          :homepage => entry.lede_photo.photo.url(:homepage),
          :large => entry.lede_photo.photo.url(:large),
          :full_size => entry.lede_photo.photo.url(:full_size),
        },
        :credit => {
          :name => entry.lede_photo.credit,
          :url => entry.lede_photo.credit_url,
        }
      } : {}
    }
  end
end

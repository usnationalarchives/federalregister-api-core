class AgencyApiRepresentation < ApiRepresentation
  field(:id)
  field(:parent_id)
  field(:child_ids){|agency| agency.children.map(&:id) || []}
  field(:child_slugs){|agency| agency.children.map(&:slug) || []}
  field(:name)
  field(:short_name) {|agency| agency.short_name.blank? ? nil : agency.short_name}
  field(:slug)
  field(:url, :select => :slug) {|agency| agency_url(agency)}
  field(:agency_url, :select => :url) {|agency| agency.url}
  field(:description)
  field(:recent_articles_url, :select => :id) {|agency| api_v1_entries_url(:conditions => {:agency_ids => [agency.id]}, :order => "newest")}
  field(:logo, :select => :logo_file_name) do |agency|
    # TODO: figure out why paperclip seems so slow--600ms for this?
    if agency.logo_file_name.present?
      logo = agency.logo
      {
        :thumb_url => logo.url(:thumb),
        :small_url => logo.url(:small),
        :medium_url => logo.url(:medium),
      }
    else
      nil
    end
  end
end

class Api::V1::SectionsController < ApiController
  def index
    publication_date = parse_pub_date(params[:conditions])
    sections = []

    Section.all.each do |section|
      sections << {
        :name => section.title,
        :slug => section.slug,
        :highlighted_documents => highlighted_documents(section, publication_date),
      }
    end

    render_json_or_jsonp(sections)

  rescue ArgumentError
    render :json => {:status => 404, :message => "Record Not Found"}, :status => 404
  end

  private

  def parse_pub_date(conditions)
    if conditions && conditions[:publication_date] && conditions[:publication_date][:is].present?
      Date.parse(params[:conditions][:publication_date][:is])
    end
  end

  def highlighted_documents(section, publication_date)
    section.
      highlighted_entries(publication_date).
      limit(6).
      map do |entry|
        {
          :document_number => entry.document_number,
          :html_url => entry_path(entry),
          :curated_title => entry.curated_title,
          :curated_abstract => entry.curated_abstract,
          :photo => entry.lede_photo.present? ? {
            :urls => {
              :navigation => entry.lede_photo.photo.url(:navigation),
              :homepage => entry.lede_photo.photo.url(:homepage),
              :small => entry.lede_photo.photo.url(:small),
              :medium => entry.lede_photo.photo.url(:medium),
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
end

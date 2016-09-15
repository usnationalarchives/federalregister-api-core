class Api::V1::SectionsController < ApiController
  include Api::ApiSectionHelper

  def index
    publication_date = parse_pub_date(params[:conditions])
    sections = {}

    Section.all.each do |section|
      sections[section.slug] = {
        :name => section.title,
        :highlighted_documents => highlighted_documents(section, publication_date),
      }
    end

    cache_for 1.day
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
      map{|entry| highlighted_entry_hash(entry)}
  end
end

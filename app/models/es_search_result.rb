class EsSearchResult < OpenStruct
  include TextHelper
  include Rails.application.routes.url_helpers

  def agencies
    agency_name_ids.map do |agency_name_id|
      BatchLoader.for(agency_name_id).batch do |agency_name_ids, loader|
        AgencyName.where(id: agency_name_ids).includes(:agency).each do |agency_name|
          agency = agency_name.agency
          result = if agency
            {
              :raw_name  => agency_name.name,
              :name      => agency.name,
              :id        => agency.id,
              :url       => agency_url(agency),
              :json_url  => api_v1_agency_url(agency.id, :format => :json),
              :parent_id => agency.parent_id,
              :slug      => agency.slug
            }
          else
            {
              :raw_name  => agency_name.name
            }
          end

          loader.call(agency_name.id, result)
        end
      end
    end
  end

  def highlights
    text = highlight
    if text
      text.values.join(' ... ')
    else
      ''
    end
  end

  def excerpts
    return excerpt if excerpt

    if abstract.present?
      truncate_words(abstract, length: 255)
    else
      nil
    end
  end

  def value(field_name)
    self.send(field_name)
  end

end

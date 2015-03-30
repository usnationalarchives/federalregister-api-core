class Api::V1::SuggestedSearchesController < ApiController
  def index
    sections = parse_sections(params[:conditions])

    if sections
      sections = Section.find(:all, :conditions => {:slug => sections})
    else
      sections = Section.all
    end

    suggested_searches = sections.inject({}) do |hsh, section|
      hsh[section.slug] = section.canned_searches.in_order.map{|search|
        suggested_search_json(search).merge({
          :documents_in_last_year => search.documents_in_last(1.year),
          :position => search.position,
        })
      }

      hsh
    end

    render_json_or_jsonp(suggested_searches)
  end

  def show
    suggested_search = CannedSearch.find_by_slug(params[:id])

    if suggested_search
      render_json_or_jsonp( suggested_search_json(suggested_search) )
    else
      render :json => {:status => 404, :message => "Record Not Found"}, :status => 404 
    end
  end

  private

  def parse_sections(conditions)
    if conditions
      conditions[:sections]
    end
  end

  def remove_blank_conditions(conditions)
    conditions.reject{|k,v| v.is_a?(String) ? v.blank? : v.all?{|k,v| v.blank?}}
  end

  def suggested_search_json(search)
    {
      :description => view_context.add_citation_links(view_context.auto_link(view_context.simple_format(search.description))),
      :slug => search.slug,
      :search_conditions => remove_blank_conditions(search.search_conditions),
      :section => search.section.slug,
      :title => search.title,
    }
  end
end

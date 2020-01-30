require 'rails_rinku'

class Api::V1::SuggestedSearchesController < ApiController
  def index
    sections = parse_sections(params[:conditions])

    if sections
      sections = Section.where(:slug => sections)
    else
      sections = Section.all
    end

    suggested_searches = sections.inject({}) do |hsh, section|
      hsh[section.slug] = section.canned_searches.in_order.map{|search|
        suggested_search_json(search).merge({
          :documents_in_last_year => search.documents_in_last(1.year),
          :documents_with_open_comment_periods => search.documents_with_open_comment_periods,
          :position => search.position,
        })
      }

      hsh
    end

    cache_for 1.day
    render_json_or_jsonp(suggested_searches)
  end

  def show
    suggested_search = CannedSearch.find_by_slug(params[:id])

    cache_for 1.day
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
    conditions.reject do |k,v|
      if v.is_a?(String)
        v.blank?
      elsif v.is_a?(Array)
        v.all?(&:blank?)
      elsif v.is_a?(Hash)
        v.all?{|k,v| v.blank?}
      else
        Honeybadger.notify("Unexpected conditions: #{conditions}")
      end
    end
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

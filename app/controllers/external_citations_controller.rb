class ExternalCitationsController < ApplicationController
  include Citations::CfrHelper

  CFR_REGEXP = /(\d+)-CFR-(\d+)(?:\.(\d+))?/

  def cfr_citation
    year = params[:year]
    title, part, section = params[:citation].match(CFR_REGEXP)[1..3]

    cfr_part = CfrPart.find_by_year_and_title_and_part(year,title,part)

    if cfr_part
      redirect_to cfr_url(year,title,cfr_part.volume,part,section)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def select_cfr_citation
    date = parse_date_from_params
    @title, @part, @section = params[:citation].match(CFR_REGEXP)[1..3]

    @candidates = CfrPart.find_all_candidates(date, @title, @part)

    respond_to do |format|
      format.html
      format.js { render :json => {:citation => params[:citation],
                                   :references => @candidates.map{|c| {:name => c.name,
                                                                       :year => c.year,
                                                                       :url  => cfr_citation_path(c.year, c.title, c.part, @section)}},
                                   :ecfr_url => ecfr_url(@title, @part) }}
    end
  end

  private

  def parse_date_from_params
    begin
      date = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end
  end

  def cfr_part(year, title, part)
  end

  def cfr_subpart(year, title, part, subpart)
  end
end

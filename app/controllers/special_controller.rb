class SpecialController < ApplicationController
  def status
    if File.exists?("#{RAILS_ROOT}/tmp/maintenance.txt")
      render plain: "Down for maintenance.", :status => 503
      return
    end

    begin
      $entry_repository.count
      render plain: "Serving requests."
    rescue
      render plain: 'Elasticsearch connection issue', status: 503
    end
  end

  def robots_dot_txt
    cache_for 1.day
    render 'robots_dot_txt.txt.erb', layout: false, content_type: 'text/plain'
  end
end

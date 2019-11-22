class SpecialController < ApplicationController
  def status
    if File.exists?("#{RAILS_ROOT}/tmp/maintenance.txt")
      render :text => "Down for maintenance.", :status => 503
      return
    end

    render :text => "Serving requests."
  end

  def robots_dot_txt
    cache_for 1.day
    render 'robots_dot_txt.txt.erb', layout: false, content_type: 'text/plain'
  end
end

class SpecialController < ApplicationController
  def status
    if File.exists?("#{RAILS_ROOT}/tmp/maintenance.txt")
      render :text => "Down for maintenance.", :status => 503
      return
    end

    current_time_on_database = Entry.connection.select_values("SELECT NOW()").first
    sphinx_query = EntrySearch.new.count
    render :text => "Current time is: #{current_time_on_database}. Document count is: #{sphinx_query}."
  end

  def robots_dot_txt
    cache_for 1.day
    render :layout => false
  end
end

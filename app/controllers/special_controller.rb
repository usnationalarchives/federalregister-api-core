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

end

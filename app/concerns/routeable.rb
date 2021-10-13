module Routeable

  def optimize_routes_generation?
    false
  end

  def url_options
    case Rails.env
    when 'development'
      {:host => "dev-fr2.criticaljuncture.org", :protocol => "https"}
    when 'test'
      {:host => "www.fr2.local", :port => 8081, :protocol => "http"}
    when 'staging'
      {:host => "fr2.criticaljuncture.org", :protocol => "https"}
    else
      {:host => "www.federalregister.gov", :protocol => "https"}
    end
  end
end

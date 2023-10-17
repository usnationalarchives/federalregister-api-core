class PrinceXmlService
  class PrinceXmlServiceFailure < StandardError; end

  def self.html_to_pdf(string, output_path)
    response = Faraday.post(url, html: string)
    if response.body.blank?
      raise PrinceXmlServiceFailure
    else
      File.open(output_path, 'wb') { |file| file.write(response.body) }
    end
  end

  def self.url
    "#{Settings.prince.host}:#{Settings.prince.port}"
  end

end

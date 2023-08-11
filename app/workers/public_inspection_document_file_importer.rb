class PublicInspectionDocumentFileImporter
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :public_inspection, :retry => 0

  attr_reader :document_number, :pdf_url, :api_session_token

  def perform(document_number, pdf_url, api_session_token)
    ActiveRecord::Base.clear_active_connections!
    @document_number   = document_number
    @pdf_url           = pdf_url
    @api_session_token = api_session_token

    start_time = Time.now
    log("Starting import for #{document_number}")

    download_file
    extract_text
    set_num_pages
    watermark_file_and_put_on_s3
    document.save!

    clean_up_tempfile
    
    log("Finished import for #{document_number} in #{(Time.now - start_time).ceil}s")
  end

  private

  def log(message)
    logger.info("[#{Time.now.strftime("%a %b %d %H:%M:%S %Z %Y")}] #{message}")
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/public_inspection_import.log")
  end

  def download_file
    response = api_client.get(pdf_url)
    if response.code == 200
      File.open(pdf_path, 'wb') do |f|
        f.write(response.body)
      end
    else
      raise "invalid response (#{response.code}) when downloading PDF: #{response.body}"
    end
  end

  def api_client
    @api_client ||= Content::PublicInspectionImporter::ApiClient.new(:session_token => api_session_token)
  end

  def watermark_file_and_put_on_s3
    document.pdf_url = pdf_url

    file = File.open(pdf_path)
    document.pdf = file
    file.close
  end

  def set_num_pages
    document.num_pages = Stevedore::Pdf.new(pdf_path).num_pages
  end

  def extract_text
    raw_text = `pdftotext -enc UTF-8 #{pdf_path} -`
    raw_text.force_encoding('UTF-8')
    raw_text.gsub!(/-{3,}/, '') # remove '----' etc
    raw_text.gsub!(/\.{4,}/, '') # remove '....' etc
    raw_text.gsub!(/_{2,}/, '') # remove '____' etc
    raw_text.gsub!(/\\\d+\\/, '') # remove '\16\' etc
    raw_text.gsub!(/\|/, '') # remove '|'
    raw_text.gsub!(/\n\d+\n\n/,"\n") # remove page numbers
    document.raw_text = raw_text
  end

  def document
    @document ||= PublicInspectionDocument.find_by_document_number(document_number)
  end

  def pdf_path
    # TODO: some sort of uniqueness here
    @file_path ||= File.join(Dir.tmpdir, "#{document_number}_PI.pdf")
  end

  def clean_up_tempfile
    File.delete(pdf_path)
  end

end

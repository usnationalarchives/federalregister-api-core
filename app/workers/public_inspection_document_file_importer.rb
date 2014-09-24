class PublicInspectionDocumentFileImporter
  @queue = :public_inspection

  def self.perform(options)
    new(options).perform
  end

  attr_reader :document_number, :pdf_url, :api_session_token, :redis_set

  def initialize(options)
    @document_number = options.fetch("document_number")
    @pdf_url = options.fetch("pdf_url")
    @api_session_token = options.fetch("api_session_token")
    @redis_set = options.fetch("redis_set")
  end

  def perform
    download_file
    extract_text
    set_num_pages
    watermark_file_and_put_on_s3
    document.save!

    clean_up_tempfile
  ensure
    mark_as_complete
  end

  private

  def download_file
    File.open(pdf_path, 'wb') do |f|
      f.write(api_client.get(pdf_url).body)
    end
  end

  def api_client
    @api_client ||= Content::PublicInspectionImporter::ApiClient.new(:session_token => api_session_token)
  end

  def watermark_file_and_put_on_s3
    document.pdf_url = pdf_url
    document.pdf = File.new(pdf_path)
  end

  def set_num_pages
    document.num_pages = Stevedore::Pdf.new(pdf_path).num_pages
  end

  def extract_text
    raw_text = `pdftotext -enc UTF-8 #{pdf_path} -`
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

  def mark_as_complete
    Redis.new.srem(redis_set, document_number)
  end
end

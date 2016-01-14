module Content::EntryImporter::FullText
  class DownloadError < StandardError; end

  extend Content::EntryImporter::Utils
  provides :full_text

  def full_text
    download_url_and_check_for_error(entry.source_url(:text))
  end

  private

  def download_url_and_check_for_error(url)
    content = ''

    begin
      retry_attempts ||= 3

      content = FederalRegisterFileRetriever.http_get(url).body_str
    rescue Curl::Err::RecvError, Curl::Err::TimeoutError
      if (retry_attempts -= 1) > 0
        sleep 10
        retry
      else
        raise Content::EntryImporter::FullText::DownloadError
      end
    end

    content
  end
end

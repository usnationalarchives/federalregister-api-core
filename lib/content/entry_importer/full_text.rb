module Content::EntryImporter::FullText
  extend Content::EntryImporter::Utils
  provides :full_text
  
  def full_text
    download_url_and_check_for_error(entry.source_url(:text))
  end
  
  private
  
  def download_url_and_check_for_error(url)
    content = ''
    15.times do
      c = FederalRegisterFileRetriever.http_get(url)

      if c.response_code == 200 && c.body_str !~ /^<html xmlns/
        content = c.body_str
        break
      else
        sleep 0.5
      end
    end
    content
  end
end
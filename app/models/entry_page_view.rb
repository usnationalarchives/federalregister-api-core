class EntryPageView < ApplicationModel
  belongs_to :entry

  def referer=(url)
    self.raw_referer = url
  end
end

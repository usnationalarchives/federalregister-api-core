module Shared
  module SectionsControllerUtilities
    def prepare_for_show(section_slug, date)
      @section = Section.find_by_slug(section_slug) or raise ActiveRecord::RecordNotFound
      @publication_date = date
      @popular_entries = @section.entries.popular(5)
      @dates_to_show = Entry.latest_publication_dates(5)
      @canned_searches = @section.canned_searches.active.in_order
    end
  end
end

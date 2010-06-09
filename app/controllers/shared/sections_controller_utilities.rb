module Shared
  module SectionsControllerUtilities
    def prepare_for_show(section_slug, date)
      @section = Section.find_by_slug(section_slug) or raise ActiveRecord::RecordNotFound
      @publication_date = date
      @highlighted_entries = @section.highlighted_entries(@publication_date)
      @popular_entries = @section.entries.popular(5)
    end
  end
end
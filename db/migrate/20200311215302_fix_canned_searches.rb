class FixCannedSearches < ActiveRecord::Migration[6.0]
  include ConditionsHelper

  def change
    CannedSearch.all.each do |canned_search|
      new_conditions = clean_conditions(canned_search.search_conditions)

      part_conditions = new_conditions.dig('cfr', 'part')
      if part_conditions.present? && part_conditions.include?('-')
        new_conditions['cfr']['part'] = part_conditions.split('-').first
      end

      canned_search.update!(search_conditions: new_conditions.to_json)
    end
  end
end

class AddSphinxConditionsToCannedSearchesAndPopulate < ActiveRecord::Migration[6.0]
  def up
    add_column :canned_searches, :sphinx_conditions, :text, :limit => 16777215

    connection.execute(<<-SQL)
      UPDATE canned_searches
      SET sphinx_conditions = search_conditions
    SQL
  end

  def down
    remove_column :canned_searches, :sphinx_conditions, :text
  end
end

class AddXmlDatesToEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :entries, :xml_based_dates, :text
  end
end

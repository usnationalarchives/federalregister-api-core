class MergeReferencedDatesIntoEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :event_type, :string
    execute "UPDATE events SET event_type = 'PublicMeeting'"
    execute "INSERT INTO events (entry_id, date, event_type) SELECT entry_id, date, IF(date_type = 'CommentDate', 'CommentsClose','EffectiveDate') FROM referenced_dates GROUP BY entry_id, date_type"
    execute "INSERT INTO events (entry_id, date, event_type) SELECT entries.id, entries.publication_date, 'CommentsOpen' FROM entries JOIN referenced_dates ON referenced_dates.entry_id = entries.id AND referenced_dates.date_type = 'CommentDate' GROUP BY entries.id"
    add_index :events, :event_type
    drop_table :referenced_dates
  end

  def self.down
    remove_index :events, :event_type
    remove_column :events, :event_type
    execute "DELETE FROM events WHERE id > 18"
    create_table "referenced_dates", :force => true do |t|
      t.integer  "entry_id"
      t.date     "date"
      t.string   "string"
      t.string   "context"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "date_type"
    end
  end
end

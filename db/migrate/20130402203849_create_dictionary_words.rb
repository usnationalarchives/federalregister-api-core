class CreateDictionaryWords < ActiveRecord::Migration
  def self.up
    create_table :dictionary_words do |t|
      t.string :word
      t.datetime :created_at
      t.integer :creator_id
    end
  end

  def self.down
    drop_table :dictionary_words
  end
end

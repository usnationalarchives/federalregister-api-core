# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090725193849) do

  create_table "agencies", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "agencies", ["name", "parent_id"], :name => "index_agencies_on_name_and_parent_id"
  add_index "agencies", ["parent_id", "name"], :name => "index_agencies_on_parent_id_and_name"

  create_table "entries", :force => true do |t|
    t.text     "title"
    t.text     "abstract"
    t.text     "contact"
    t.text     "dates"
    t.text     "action"
    t.string   "type"
    t.string   "link"
    t.string   "genre"
    t.string   "part_name"
    t.string   "citation"
    t.string   "granule_class"
    t.string   "document_number"
    t.string   "toc_subject"
    t.string   "toc_doc"
    t.integer  "length"
    t.integer  "start_page"
    t.integer  "end_page"
    t.integer  "agency_id"
    t.date     "publication_date"
    t.date     "effective_date"
    t.datetime "places_determined_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "slug"
  end

  add_index "entries", ["agency_id"], :name => "index_entries_on_agency_id"
  add_index "entries", ["document_number"], :name => "index_entries_on_document_number"

  create_table "place_determinations", :force => true do |t|
    t.integer "entry_id"
    t.integer "place_id"
    t.string  "string"
    t.string  "context"
    t.integer "confidence"
  end

  add_index "place_determinations", ["entry_id", "confidence"], :name => "index_place_determinations_on_entry_id_and_confidence"
  add_index "place_determinations", ["place_id", "confidence"], :name => "index_place_determinations_on_place_id_and_confidence"

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "place_type"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referenced_dates", :force => true do |t|
    t.integer  "entry_id"
    t.date     "date"
    t.string   "string"
    t.string   "context"
    t.boolean  "prospective"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referenced_dates", ["entry_id", "date"], :name => "index_referenced_dates_on_entry_id_and_date"

  create_table "topic_assignments", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_assignments", ["entry_id"], :name => "index_topic_assignments_on_entry_id"
  add_index "topic_assignments", ["topic_id"], :name => "index_topic_assignments_on_topic_id"

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["name"], :name => "index_topics_on_name"

  create_table "url_references", :force => true do |t|
    t.integer  "url_id"
    t.integer  "entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "url_references", ["entry_id"], :name => "index_url_references_on_entry_id"
  add_index "url_references", ["url_id"], :name => "index_url_references_on_url_id"

  create_table "urls", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "content_type"
    t.integer  "response_code"
    t.float    "content_length"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "urls", ["name"], :name => "index_urls_on_name"
  add_index "urls", ["type"], :name => "index_urls_on_type"

end

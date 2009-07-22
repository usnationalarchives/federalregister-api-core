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

ActiveRecord::Schema.define(:version => 20090722141043) do

  create_table "agencies", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agencies", ["name"], :name => "index_agencies_on_name"

  create_table "agency_assignments", :force => true do |t|
    t.integer  "agency_id"
    t.integer  "entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agency_assignments", ["agency_id"], :name => "index_agency_assignments_on_agency_id"
  add_index "agency_assignments", ["entry_id"], :name => "index_agency_assignments_on_entry_id"

  create_table "entries", :force => true do |t|
    t.string   "type"
    t.string   "identifier"
    t.string   "link"
    t.string   "genre"
    t.string   "title"
    t.string   "part_name"
    t.string   "citation"
    t.string   "abstract"
    t.integer  "length"
    t.integer  "start_page"
    t.integer  "end_page"
    t.string   "search_title"
    t.string   "granule_class"
    t.string   "document_number"
    t.string   "effective_date"
    t.string   "action"
    t.string   "dates"
    t.string   "contact"
    t.string   "toc_subject"
    t.string   "toc_doc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "urls", ["name"], :name => "index_urls_on_name"
  add_index "urls", ["type"], :name => "index_urls_on_type"

end

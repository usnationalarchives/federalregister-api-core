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

ActiveRecord::Schema.define(:version => 20100117214210) do

  create_table "agencies", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "agency_type"
    t.string   "short_name"
    t.text     "description"
    t.text     "more_information"
    t.integer  "entries_count"
    t.text     "entries_1_year_weekly"
    t.text     "entries_5_years_monthly"
    t.text     "entries_all_years_quarterly"
    t.text     "related_topics_cache"
  end

  add_index "agencies", ["name", "parent_id"], :name => "index_agencies_on_name_and_parent_id"
  add_index "agencies", ["parent_id", "name"], :name => "index_agencies_on_parent_id_and_name"

  create_table "citations", :force => true do |t|
    t.integer "source_entry_id"
    t.integer "cited_entry_id"
    t.string  "citation_type"
    t.string  "part_1"
    t.string  "part_2"
    t.string  "part_3"
  end

  add_index "citations", ["cited_entry_id", "citation_type", "source_entry_id"], :name => "cited_citation_source"
  add_index "citations", ["source_entry_id", "citation_type", "cited_entry_id"], :name => "source_citation_cited"

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
    t.datetime "places_determined_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "slug"
    t.boolean  "delta",                        :default => true, :null => false
    t.string   "source_text_url"
    t.string   "primary_agency_raw"
    t.string   "secondary_agency_raw"
    t.string   "regulationsdotgov_id"
    t.string   "comment_url"
    t.datetime "checked_regulationsdotgov_at"
    t.integer  "volume"
    t.datetime "full_xml_updated_at"
    t.string   "regulation_id_number"
    t.integer  "citing_entries_count",         :default => 0
    t.string   "document_file_path"
    t.datetime "full_text_updated_at"
  end

  add_index "entries", ["agency_id", "citing_entries_count"], :name => "index_entries_on_agency_id_and_citing_entries_count"
  add_index "entries", ["agency_id", "granule_class"], :name => "index_entries_on_agency_id_and_granule_class"
  add_index "entries", ["agency_id", "id"], :name => "index_entries_on_agency_id_and_id"
  add_index "entries", ["agency_id", "publication_date"], :name => "index_entries_on_agency_id_and_publication_date"
  add_index "entries", ["citation"], :name => "index_entries_on_citation"
  add_index "entries", ["citing_entries_count"], :name => "index_entries_on_citing_entries_count"
  add_index "entries", ["document_number"], :name => "index_entries_on_document_number"
  add_index "entries", ["full_text_updated_at"], :name => "index_entries_on_full_text_added_at"
  add_index "entries", ["full_xml_updated_at"], :name => "index_entries_on_full_xml_added_at"
  add_index "entries", ["id", "publication_date"], :name => "index_entries_on_id_and_publication_date"
  add_index "entries", ["publication_date", "agency_id"], :name => "index_entries_on_publication_date_and_agency_id"
  add_index "entries", ["regulation_id_number"], :name => "index_entries_on_regulation_id_number"
  add_index "entries", ["volume", "start_page", "end_page"], :name => "index_entries_on_volume_and_start_page_and_end_page"

  create_table "entry_details", :force => true do |t|
    t.integer "entry_id"
    t.text    "full_text_raw", :limit => 2147483647
  end

  add_index "entry_details", ["entry_id"], :name => "index_entry_details_on_entry_id"

  create_table "place_determinations", :force => true do |t|
    t.integer "entry_id"
    t.integer "place_id"
    t.string  "string"
    t.string  "context"
    t.integer "confidence"
  end

  add_index "place_determinations", ["entry_id", "confidence", "place_id"], :name => "index_place_determinations_on_entry_id_and_place_id"
  add_index "place_determinations", ["place_id", "confidence", "entry_id"], :name => "index_place_determinations_on_place_id_and_entry_id"

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "date_type"
  end

  add_index "referenced_dates", ["entry_id", "date"], :name => "index_referenced_dates_on_entry_id_and_date"

  create_table "topic_assignments", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_assignments", ["entry_id", "topic_id"], :name => "index_topic_assignments_on_entry_id_and_topic_id"
  add_index "topic_assignments", ["topic_id", "entry_id"], :name => "index_topic_assignments_on_topic_id_and_entry_id"

  create_table "topic_groups", :id => false, :force => true do |t|
    t.string  "group_name"
    t.string  "name"
    t.integer "entries_count",          :limit => 32, :precision => 32, :scale => 0
    t.text    "related_topics_cache"
    t.text    "related_agencies_cache"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_name"
    t.integer  "entries_count",          :default => 0
    t.text     "related_topics_cache"
    t.text     "related_agencies_cache"
  end

  add_index "topics", ["entries_count"], :name => "index_topics_on_entries_count"
  add_index "topics", ["group_name", "id"], :name => "index_topics_on_group_name_and_id"
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

  create_table "user_list_items", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "user_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_list_items", ["entry_id"], :name => "index_user_list_items_on_entry_id"
  add_index "user_list_items", ["user_list_id"], :name => "index_user_list_items_on_user_list_id"

  create_table "user_lists", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "slug"
    t.boolean  "public",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_lists", ["user_id"], :name => "index_user_lists_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                              :null => false
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end

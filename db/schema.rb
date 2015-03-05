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

ActiveRecord::Schema.define(:version => 20141111200846) do

  create_table "action_names", :force => true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "action_names_document_subtypes", :id => false, :force => true do |t|
    t.integer "action_name_id"
    t.integer "document_subtype_id"
  end

  add_index "action_names_document_subtypes", ["action_name_id", "document_subtype_id"], :name => "action_name_id"

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
    t.integer  "entries_count",               :default => 0, :null => false
    t.text     "entries_1_year_weekly"
    t.text     "entries_5_years_monthly"
    t.text     "entries_all_years_quarterly"
    t.text     "related_topics_cache"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "url"
    t.boolean  "active"
    t.text     "cfr_citation"
    t.string   "display_name"
    t.string   "pseudonym"
  end

  add_index "agencies", ["name", "parent_id"], :name => "index_agencies_on_name_and_parent_id"
  add_index "agencies", ["parent_id", "name"], :name => "index_agencies_on_parent_id_and_name"

  create_table "agencies_sections", :force => true do |t|
    t.integer  "section_id"
    t.integer  "agency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "agencies_sections", ["agency_id", "section_id"], :name => "index_agencies_sections_on_agency_id_and_section_id"
  add_index "agencies_sections", ["section_id", "agency_id"], :name => "index_agencies_sections_on_section_id_and_agency_id"

  create_table "agency_assignments", :force => true do |t|
    t.integer "assignable_id"
    t.integer "agency_id"
    t.integer "position"
    t.string  "assignable_type"
    t.integer "agency_name_id"
  end

  add_index "agency_assignments", ["agency_id", "assignable_id"], :name => "index_agency_assignments_on_agency_id_and_entry_id"
  add_index "agency_assignments", ["agency_name_id"], :name => "index_agency_assignments_on_agency_name_id"
  add_index "agency_assignments", ["assignable_type", "assignable_id", "agency_id"], :name => "index_agency_assignments_on_assignable_and_agency_id"

  create_table "agency_highlights", :force => true do |t|
    t.integer "entry_id"
    t.integer "agency_id"
    t.date    "highlight_until"
    t.boolean "published",       :default => false
    t.string  "section_header"
    t.string  "title"
    t.string  "abstract"
  end

  add_index "agency_highlights", ["highlight_until"], :name => "index_agency_highlights_on_highlight_until"

  create_table "agency_name_assignments", :force => true do |t|
    t.integer "assignable_id"
    t.integer "agency_name_id"
    t.integer "position"
    t.string  "assignable_type"
  end

  add_index "agency_name_assignments", ["agency_name_id", "assignable_id"], :name => "index_agency_name_assignments_on_agency_name_id_and_entry_id"
  add_index "agency_name_assignments", ["assignable_type", "assignable_id", "agency_name_id"], :name => "index_agency_name_assignments_on_assignable_and_agency_name_id"

  create_table "agency_names", :force => true do |t|
    t.string   "name",                          :null => false
    t.integer  "agency_id"
    t.boolean  "void",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agency_names", ["agency_id", "name"], :name => "index_agency_names_on_agency_id_and_name"
  add_index "agency_names", ["name", "agency_id"], :name => "index_agency_names_on_name_and_agency_id"
  add_index "agency_names", ["name"], :name => "index_agency_names_on_name", :unique => true

  create_table "canned_searches", :force => true do |t|
    t.integer "section_id"
    t.string  "title"
    t.string  "slug"
    t.text    "description",       :limit => 16777215
    t.text    "search_conditions", :limit => 16777215
    t.boolean "active"
    t.integer "position"
  end

  add_index "canned_searches", ["section_id", "active"], :name => "index_canned_searches_on_section_id_and_active"
  add_index "canned_searches", ["slug"], :name => "index_canned_searches_on_slug"

  create_table "cfr_parts", :force => true do |t|
    t.integer "year"
    t.integer "title"
    t.integer "part"
    t.integer "volume"
    t.string  "name"
  end

  add_index "cfr_parts", ["year", "title", "part"], :name => "index_cfr_parts_on_year_and_title_and_part"

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

  create_table "clippings", :force => true do |t|
    t.integer  "user_id"
    t.string   "document_number"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dictionary_words", :force => true do |t|
    t.string   "word"
    t.datetime "created_at"
    t.integer  "creator_id"
  end

  create_table "docket_documents", :id => false, :force => true do |t|
    t.string "id"
    t.string "docket_id"
    t.string "title"
    t.text   "metadata"
  end

  add_index "docket_documents", ["docket_id"], :name => "index_docket_documents_on_docket_id"

  create_table "docket_numbers", :force => true do |t|
    t.string  "number"
    t.string  "assignable_type"
    t.integer "assignable_id"
    t.integer "position",        :default => 0, :null => false
  end

  add_index "docket_numbers", ["assignable_type", "assignable_id"], :name => "index_docket_numbers_on_assignable_type_and_assignable_id"

  create_table "dockets", :force => true do |t|
    t.string  "regulation_id_number"
    t.integer "comments_count"
    t.integer "docket_documents_count"
    t.string  "title"
    t.text    "metadata"
  end

  create_table "document_subtypes", :force => true do |t|
    t.string "granule_class"
    t.string "name"
  end

  create_table "entries", :force => true do |t|
    t.text     "title"
    t.text     "abstract"
    t.text     "contact"
    t.text     "dates"
    t.text     "action"
    t.string   "part_name"
    t.string   "citation"
    t.string   "granule_class"
    t.string   "document_number"
    t.string   "toc_subject",                   :limit => 1000
    t.string   "toc_doc",                       :limit => 1000
    t.integer  "start_page"
    t.integer  "end_page"
    t.date     "publication_date"
    t.datetime "places_determined_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                                         :default => true,  :null => false
    t.string   "source_text_url"
    t.string   "regulationsdotgov_url"
    t.string   "comment_url"
    t.datetime "checked_regulationsdotgov_at"
    t.integer  "volume"
    t.datetime "full_xml_updated_at"
    t.integer  "citing_entries_count",                          :default => 0
    t.string   "document_file_path"
    t.datetime "full_text_updated_at"
    t.string   "curated_title"
    t.string   "curated_abstract",              :limit => 500
    t.integer  "lede_photo_id"
    t.text     "lede_photo_candidates"
    t.datetime "raw_text_updated_at"
    t.boolean  "significant",                                   :default => false
    t.integer  "presidential_document_type_id"
    t.date     "signing_date"
    t.integer  "executive_order_number"
    t.integer  "action_name_id"
    t.integer  "correction_of_id"
    t.string   "regulations_dot_gov_docket_id"
    t.text     "executive_order_notes"
    t.string   "fr_index_subject"
    t.string   "fr_index_doc"
    t.integer  "issue_number"
  end

  add_index "entries", ["citation"], :name => "index_entries_on_citation"
  add_index "entries", ["citing_entries_count"], :name => "index_entries_on_agency_id_and_citing_entries_count"
  add_index "entries", ["citing_entries_count"], :name => "index_entries_on_citing_entries_count"
  add_index "entries", ["correction_of_id"], :name => "index_entries_on_correction_of"
  add_index "entries", ["delta"], :name => "index_entries_on_delta"
  add_index "entries", ["document_number"], :name => "index_entries_on_document_number"
  add_index "entries", ["full_text_updated_at"], :name => "index_entries_on_full_text_added_at"
  add_index "entries", ["full_xml_updated_at"], :name => "index_entries_on_full_xml_added_at"
  add_index "entries", ["granule_class"], :name => "index_entries_on_agency_id_and_granule_class"
  add_index "entries", ["id", "publication_date"], :name => "index_entries_on_id_and_publication_date"
  add_index "entries", ["id"], :name => "index_entries_on_agency_id_and_id"
  add_index "entries", ["presidential_document_type_id", "executive_order_number"], :name => "presdocu_type_id_and_eo_number"
  add_index "entries", ["publication_date"], :name => "index_entries_on_agency_id_and_publication_date"
  add_index "entries", ["publication_date"], :name => "index_entries_on_publication_date_and_agency_id"
  add_index "entries", ["raw_text_updated_at"], :name => "index_entries_on_raw_text_updated_at"
  add_index "entries", ["significant"], :name => "index_entries_on_significant"
  add_index "entries", ["volume", "start_page", "id"], :name => "index_entries_on_volume_and_start_page_and_id"

  create_table "entry_cfr_references", :force => true do |t|
    t.integer "entry_id"
    t.integer "title"
    t.integer "part"
    t.integer "chapter"
  end

  add_index "entry_cfr_references", ["entry_id"], :name => "index_entry_cfr_affected_parts_on_entry_id"

  create_table "entry_emails", :force => true do |t|
    t.string   "remote_ip"
    t.integer  "num_recipients"
    t.integer  "entry_id"
    t.string   "sender_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entry_page_views", :force => true do |t|
    t.integer  "entry_id"
    t.datetime "created_at"
    t.string   "remote_ip"
    t.text     "raw_referer", :limit => 16777215
  end

  add_index "entry_page_views", ["created_at"], :name => "index_entry_page_views_on_created_at"
  add_index "entry_page_views", ["entry_id"], :name => "index_entry_page_views_on_entry_id"

  create_table "entry_page_views_archive", :force => true do |t|
    t.integer  "entry_id"
    t.datetime "created_at"
    t.string   "remote_ip"
    t.text     "raw_referer", :limit => 16777215
  end

  add_index "entry_page_views_archive", ["created_at"], :name => "index_entry_page_views_on_created_at"
  add_index "entry_page_views_archive", ["entry_id"], :name => "index_entry_page_views_on_entry_id"

  create_table "entry_regulation_id_numbers", :force => true do |t|
    t.integer "entry_id"
    t.string  "regulation_id_number"
  end

  add_index "entry_regulation_id_numbers", ["entry_id", "regulation_id_number"], :name => "index"
  add_index "entry_regulation_id_numbers", ["regulation_id_number", "entry_id"], :name => "rin_then_entry"

  create_table "events", :force => true do |t|
    t.integer "entry_id"
    t.date    "date"
    t.string  "title"
    t.integer "place_id"
    t.boolean "remote_call_in_available"
    t.string  "event_type"
    t.boolean "delta",                    :default => true, :null => false
  end

  add_index "events", ["delta"], :name => "index_events_on_delta"
  add_index "events", ["event_type", "entry_id", "date"], :name => "index_events_on_event_type_and_entry_id_and_date"
  add_index "events", ["event_type", "entry_id", "place_id"], :name => "index_events_on_event_type_and_entry_id_and_place_id"
  add_index "events", ["event_type", "place_id", "entry_id"], :name => "index_events_on_event_type_and_place_id_and_entry_id"

  create_table "fr_index_agency_statuses", :force => true do |t|
    t.integer "year"
    t.integer "agency_id"
    t.date    "last_completed_issue"
    t.integer "needs_attention_count"
    t.date    "oldest_issue_needing_attention"
    t.date    "last_published"
  end

  add_index "fr_index_agency_statuses", ["year", "agency_id"], :name => "index_fr_index_agency_statuses_on_year_and_agency_id"

  create_table "generated_files", :force => true do |t|
    t.string   "parameters"
    t.string   "token"
    t.datetime "processing_began_at"
    t.datetime "processing_completed_at"
    t.string   "attachment_file_name"
    t.string   "attachment_file_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_document_count"
    t.integer  "processed_document_count"
  end

  create_table "graphic_usages", :force => true do |t|
    t.integer "graphic_id"
    t.integer "entry_id"
  end

  add_index "graphic_usages", ["entry_id", "graphic_id"], :name => "index_graphic_usages_on_entry_id_and_graphic_id"
  add_index "graphic_usages", ["graphic_id", "entry_id"], :name => "index_graphic_usages_on_graphic_id_and_entry_id"

  create_table "graphics", :force => true do |t|
    t.string   "identifier"
    t.integer  "usage_count",          :default => 0, :null => false
    t.string   "graphic_file_name"
    t.string   "graphic_content_type"
    t.integer  "graphic_file_size"
    t.datetime "graphic_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "inverted"
  end

  add_index "graphics", ["identifier"], :name => "index_graphics_on_identifier", :unique => true

  create_table "issue_approvals", :force => true do |t|
    t.date     "publication_date"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_approvals", ["publication_date"], :name => "index_issue_approvals_on_publication_date"

  create_table "issues", :force => true do |t|
    t.date     "publication_date"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lede_photos", :force => true do |t|
    t.string   "credit"
    t.string   "credit_url"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "url"
    t.integer  "crop_width"
    t.integer  "crop_height"
    t.integer  "crop_x"
    t.integer  "crop_y"
  end

  create_table "mailing_lists", :force => true do |t|
    t.text     "search_conditions",          :limit => 16777215
    t.string   "title"
    t.integer  "active_subscriptions_count",                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

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

  create_table "public_inspection_documents", :force => true do |t|
    t.string   "document_number"
    t.string   "granule_class"
    t.datetime "filed_at"
    t.date     "publication_date"
    t.boolean  "special_filing",                          :default => false, :null => false
    t.string   "pdf_file_name"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.text     "editorial_note",      :limit => 16777215
    t.string   "document_file_path"
    t.datetime "raw_text_updated_at"
    t.boolean  "delta",                                   :default => true,  :null => false
    t.integer  "num_pages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entry_id"
    t.string   "subject_1"
    t.string   "subject_2"
    t.string   "subject_3"
    t.string   "pdf_url"
    t.string   "category"
    t.datetime "update_pil_at"
  end

  add_index "public_inspection_documents", ["delta"], :name => "index_public_inspection_documents_on_delta"
  add_index "public_inspection_documents", ["document_number"], :name => "index_public_inspection_documents_on_document_number"
  add_index "public_inspection_documents", ["entry_id"], :name => "index_public_inspection_documents_on_entry_id"
  add_index "public_inspection_documents", ["publication_date"], :name => "index_public_inspection_documents_on_publication_date"

  create_table "public_inspection_issues", :force => true do |t|
    t.date     "publication_date"
    t.datetime "published_at"
    t.datetime "special_filings_updated_at"
    t.datetime "regular_filings_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public_inspection_postings", :id => false, :force => true do |t|
    t.integer "issue_id"
    t.integer "document_id"
  end

  add_index "public_inspection_postings", ["issue_id", "document_id"], :name => "index_public_inspection_postings_on_issue_id_and_document_id"

  create_table "regulatory_plan_events", :force => true do |t|
    t.integer "regulatory_plan_id"
    t.string  "date"
    t.string  "action"
    t.string  "fr_citation"
  end

  add_index "regulatory_plan_events", ["regulatory_plan_id"], :name => "index_regulatory_plan_events_on_regulatory_plan_id"

  create_table "regulatory_plans", :force => true do |t|
    t.string  "regulation_id_number"
    t.string  "issue"
    t.text    "title",                :limit => 16777215
    t.text    "abstract",             :limit => 16777215
    t.string  "priority_category"
    t.boolean "delta",                                    :default => true, :null => false
    t.boolean "current"
  end

  add_index "regulatory_plans", ["current", "regulation_id_number"], :name => "index_regulatory_plans_on_current_and_regulation_id_number"
  add_index "regulatory_plans", ["delta"], :name => "index_regulatory_plans_on_delta"
  add_index "regulatory_plans", ["issue", "regulation_id_number"], :name => "index_regulatory_plans_on_issue_and_regulation_id_number"
  add_index "regulatory_plans", ["regulation_id_number", "issue"], :name => "index_regulatory_plans_on_regulation_id_number_and_issue"

  create_table "regulatory_plans_small_entities", :id => false, :force => true do |t|
    t.integer "regulatory_plan_id"
    t.integer "small_entity_id"
  end

  add_index "regulatory_plans_small_entities", ["regulatory_plan_id", "small_entity_id"], :name => "reg_then_entity"

  create_table "section_assignments", :force => true do |t|
    t.integer "entry_id"
    t.integer "section_id"
  end

  add_index "section_assignments", ["entry_id", "section_id"], :name => "index_section_assignments_on_entry_id_and_section_id"
  add_index "section_assignments", ["section_id", "entry_id"], :name => "index_section_assignments_on_section_id_and_entry_id"

  create_table "section_highlights", :force => true do |t|
    t.integer "section_id"
    t.integer "entry_id"
    t.integer "position"
    t.date    "publication_date"
  end

  add_index "section_highlights", ["section_id", "entry_id"], :name => "index_section_highlights_on_section_id_and_entry_id"

  create_table "sections", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.integer  "position"
    t.text     "description",           :limit => 16777215
    t.text     "relevant_cfr_sections", :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  create_table "site_notifications", :force => true do |t|
    t.string  "identifier"
    t.string  "notification_type"
    t.text    "description"
    t.boolean "active"
  end

  create_table "small_entities", :force => true do |t|
    t.string "name"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "mailing_list_id"
    t.string   "email"
    t.string   "requesting_ip"
    t.string   "token"
    t.datetime "confirmed_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_delivered_at"
    t.integer  "delivery_count",       :default => 0
    t.date     "last_issue_delivered"
    t.string   "environment"
  end

  create_table "topic_assignments", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topics_topic_name_id"
  end

  add_index "topic_assignments", ["entry_id", "topic_id"], :name => "index_topic_assignments_on_entry_id_and_topic_id"
  add_index "topic_assignments", ["topic_id", "entry_id"], :name => "index_topic_assignments_on_topic_id_and_entry_id"
  add_index "topic_assignments", ["topics_topic_name_id"], :name => "index_topic_assignments_on_topics_topic_name_id"

  create_table "topic_name_assignments", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "topic_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_name_assignments", ["entry_id", "topic_name_id"], :name => "index_topic_name_assignments_on_entry_id_and_topic_name_id"
  add_index "topic_name_assignments", ["topic_name_id", "entry_id"], :name => "index_topic_name_assignments_on_topic_name_id_and_entry_id"

  create_table "topic_names", :force => true do |t|
    t.string   "name"
    t.boolean  "void",          :default => false
    t.integer  "entries_count", :default => 0
    t.integer  "topics_count",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_names", ["name"], :name => "index_topic_names_on_name"
  add_index "topic_names", ["void", "topics_count"], :name => "index_topic_names_on_void_and_topics_count"

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "entries_count",          :default => 0
    t.text     "related_topics_cache"
    t.text     "related_agencies_cache"
  end

  add_index "topics", ["entries_count"], :name => "index_topics_on_entries_count"
  add_index "topics", ["name"], :name => "index_topics_on_name"
  add_index "topics", ["slug", "id"], :name => "index_topics_on_group_name_and_id"

  create_table "topics_topic_names", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "topic_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "topics_topic_names", ["topic_id", "topic_name_id"], :name => "index_topics_topic_names_on_topic_id_and_topic_name_id"
  add_index "topics_topic_names", ["topic_name_id", "topic_id"], :name => "index_topics_topic_names_on_topic_name_id_and_topic_id"

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

  create_table "users", :force => true do |t|
    t.string   "email",                                 :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                     :null => false
    t.string   "single_access_token",                   :null => false
    t.string   "perishable_token",                      :null => false
    t.integer  "login_count",         :default => 0,    :null => false
    t.integer  "failed_login_count",  :default => 0,    :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "active",              :default => true
  end

end

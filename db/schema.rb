# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_11_07_183831) do

  create_table "action_names", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agencies", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "parent_id"
    t.string "name", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", collation: "utf8_general_ci"
    t.string "agency_type", collation: "utf8_general_ci"
    t.string "short_name", collation: "utf8_general_ci"
    t.text "description", collation: "utf8_general_ci"
    t.text "more_information", collation: "utf8_general_ci"
    t.integer "entries_count", default: 0, null: false
    t.text "entries_1_year_weekly", collation: "utf8_general_ci"
    t.text "entries_5_years_monthly", collation: "utf8_general_ci"
    t.text "entries_all_years_quarterly", collation: "utf8_general_ci"
    t.text "related_topics_cache", collation: "utf8_general_ci"
    t.string "logo_file_name", collation: "utf8_general_ci"
    t.string "logo_content_type", collation: "utf8_general_ci"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "url", collation: "utf8_general_ci"
    t.boolean "active"
    t.text "cfr_citation", collation: "utf8_general_ci"
    t.string "display_name", collation: "utf8_general_ci"
    t.string "pseudonym", collation: "utf8_general_ci"
    t.string "pai_identifier"
    t.integer "pai_year"
    t.index ["name", "parent_id"], name: "index_agencies_on_name_and_parent_id"
    t.index ["parent_id", "name"], name: "index_agencies_on_parent_id_and_name"
  end

  create_table "agencies_sections", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "section_id"
    t.integer "agency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["agency_id", "section_id"], name: "index_agencies_sections_on_agency_id_and_section_id"
    t.index ["section_id", "agency_id"], name: "index_agencies_sections_on_section_id_and_agency_id"
  end

  create_table "agency_assignments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "assignable_id"
    t.integer "agency_id"
    t.integer "position"
    t.string "assignable_type", collation: "utf8_general_ci"
    t.integer "agency_name_id"
    t.index ["agency_id", "assignable_id"], name: "index_agency_assignments_on_agency_id_and_entry_id"
    t.index ["agency_name_id"], name: "index_agency_assignments_on_agency_name_id"
    t.index ["assignable_type", "assignable_id", "agency_id"], name: "index_agency_assignments_on_assignable_and_agency_id"
  end

  create_table "agency_assignments_archive", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "assignable_id"
    t.integer "agency_id"
    t.integer "position"
    t.string "assignable_type", collation: "utf8_general_ci"
    t.integer "agency_name_id"
    t.index ["agency_id", "assignable_id"], name: "index_agency_assignments_on_agency_id_and_entry_id"
    t.index ["agency_name_id"], name: "index_agency_assignments_on_agency_name_id"
    t.index ["assignable_type", "assignable_id", "agency_id"], name: "index_agency_assignments_on_assignable_and_agency_id"
  end

  create_table "agency_highlights", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.integer "agency_id"
    t.date "highlight_until"
    t.boolean "published", default: false
    t.string "section_header", collation: "utf8_general_ci"
    t.string "title", collation: "utf8_general_ci"
    t.string "abstract", collation: "utf8_general_ci"
    t.index ["highlight_until"], name: "index_agency_highlights_on_highlight_until"
  end

  create_table "agency_name_assignments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "assignable_id"
    t.integer "agency_name_id"
    t.integer "position"
    t.string "assignable_type", collation: "utf8_general_ci"
    t.index ["agency_name_id", "assignable_id"], name: "index_agency_name_assignments_on_agency_name_id_and_entry_id"
    t.index ["assignable_type", "assignable_id", "agency_name_id"], name: "index_agency_name_assignments_on_assignable_and_agency_name_id"
  end

  create_table "agency_names", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false, collation: "utf8_general_ci"
    t.integer "agency_id"
    t.boolean "void", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["agency_id", "name"], name: "index_agency_names_on_agency_id_and_name"
    t.index ["name", "agency_id"], name: "index_agency_names_on_name_and_agency_id"
    t.index ["name"], name: "index_agency_names_on_name", unique: true
  end

  create_table "canned_searches", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "section_id"
    t.string "title", collation: "utf8_general_ci"
    t.string "slug", collation: "utf8_general_ci"
    t.text "description", size: :medium, collation: "utf8_general_ci"
    t.text "search_conditions", size: :medium, collation: "utf8_general_ci"
    t.boolean "active"
    t.integer "position"
    t.text "sphinx_conditions", size: :medium
    t.index ["section_id", "active"], name: "index_canned_searches_on_section_id_and_active"
    t.index ["slug"], name: "index_canned_searches_on_slug"
  end

  create_table "cfr_parts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "year"
    t.integer "title"
    t.integer "part"
    t.integer "volume"
    t.string "name", collation: "utf8_general_ci"
    t.index ["year", "title", "part"], name: "index_cfr_parts_on_year_and_title_and_part"
  end

  create_table "citations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "source_entry_id"
    t.integer "cited_entry_id"
    t.string "citation_type", collation: "utf8_general_ci"
    t.string "part_1", collation: "utf8_general_ci"
    t.string "part_2", collation: "utf8_general_ci"
    t.string "part_3", collation: "utf8_general_ci"
    t.index ["cited_entry_id", "citation_type", "source_entry_id"], name: "cited_citation_source"
    t.index ["source_entry_id", "citation_type", "cited_entry_id"], name: "source_citation_cited"
  end

  create_table "dictionary_words", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "word", collation: "latin1_swedish_ci"
    t.datetime "created_at"
    t.integer "creator_id"
  end

  create_table "docket_numbers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "number"
    t.string "assignable_type"
    t.integer "assignable_id"
    t.integer "position", default: 0
    t.index ["assignable_type", "assignable_id"], name: "index_docket_numbers_on_assignable_type_and_assignable_id"
  end

  create_table "entries", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "title", collation: "utf8_general_ci"
    t.text "abstract", collation: "utf8_general_ci"
    t.text "contact", collation: "utf8_general_ci"
    t.text "dates", collation: "utf8_general_ci"
    t.text "action", collation: "utf8_general_ci"
    t.string "part_name", collation: "utf8_general_ci"
    t.string "citation", collation: "utf8_general_ci"
    t.string "granule_class", collation: "utf8_general_ci"
    t.string "document_number", collation: "utf8_general_ci"
    t.string "toc_subject", limit: 2000
    t.string "toc_doc", limit: 2000
    t.integer "start_page"
    t.integer "end_page"
    t.date "publication_date"
    t.datetime "places_determined_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "source_text_url", collation: "utf8_general_ci"
    t.string "regulationsdotgov_url", collation: "utf8_general_ci"
    t.string "comment_url", collation: "utf8_general_ci"
    t.datetime "checked_regulationsdotgov_at"
    t.integer "volume"
    t.datetime "full_xml_updated_at"
    t.integer "citing_entries_count", default: 0
    t.string "document_file_path", collation: "utf8_general_ci"
    t.datetime "full_text_updated_at"
    t.string "curated_title", collation: "utf8_general_ci"
    t.string "curated_abstract", limit: 500, collation: "utf8_general_ci"
    t.integer "lede_photo_id"
    t.text "lede_photo_candidates", collation: "utf8_general_ci"
    t.datetime "raw_text_updated_at"
    t.boolean "significant", default: false
    t.integer "presidential_document_type_id"
    t.date "signing_date"
    t.integer "action_name_id"
    t.integer "correction_of_id"
    t.string "regulations_dot_gov_docket_id", collation: "utf8_general_ci"
    t.text "executive_order_notes", collation: "utf8_general_ci"
    t.string "fr_index_subject", collation: "utf8_general_ci"
    t.string "fr_index_doc", limit: 1023
    t.integer "issue_number"
    t.string "comment_url_override", collation: "utf8_general_ci"
    t.string "presidential_document_number"
    t.string "regulations_dot_gov_document_id"
    t.integer "comment_count"
    t.integer "issue_part_id"
    t.integer "universal_analytics_page_views"
    t.boolean "not_received_for_publication"
    t.integer "president_id"
    t.integer "historical_page_view_count"
    t.string "sorn_system_name"
    t.string "sorn_system_number"
    t.integer "notice_type_id"
    t.text "xml_based_dates"
    t.index ["citation"], name: "index_entries_on_citation"
    t.index ["citing_entries_count"], name: "index_entries_on_citing_entries_count"
    t.index ["correction_of_id"], name: "index_entries_on_correction_of"
    t.index ["document_number"], name: "index_entries_on_document_number"
    t.index ["full_text_updated_at"], name: "index_entries_on_full_text_added_at"
    t.index ["full_xml_updated_at"], name: "index_entries_on_full_xml_added_at"
    t.index ["granule_class"], name: "index_entries_on_agency_id_and_granule_class"
    t.index ["id", "publication_date"], name: "index_entries_on_id_and_publication_date"
    t.index ["id"], name: "index_entries_on_agency_id_and_id"
    t.index ["issue_part_id"], name: "index_entries_on_issue_part_id"
    t.index ["presidential_document_number", "presidential_document_type_id"], name: "pres_doc_number_pres_doc_type_id", length: { presidential_document_number: 10 }
    t.index ["presidential_document_type_id", "presidential_document_number"], name: "presidential_document_type_id", length: { presidential_document_number: 10 }
    t.index ["publication_date"], name: "index_entries_on_agency_id_and_publication_date"
    t.index ["raw_text_updated_at"], name: "index_entries_on_raw_text_updated_at"
    t.index ["significant"], name: "index_entries_on_significant"
    t.index ["volume", "end_page", "start_page"], name: "index_entries_on_volume_and_end_page_and_start_page"
    t.index ["volume", "start_page", "id"], name: "index_entries_on_volume_and_start_page_and_id"
  end

  create_table "entry_cfr_references", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.integer "title"
    t.integer "part"
    t.integer "chapter"
    t.index ["entry_id"], name: "index_entry_cfr_affected_parts_on_entry_id"
  end

  create_table "entry_changes", charset: "utf8mb4", force: :cascade do |t|
    t.integer "entry_id"
    t.index ["entry_id"], name: "index_entry_changes_on_entry_id", unique: true
  end

  create_table "entry_emails", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "remote_ip", collation: "utf8_general_ci"
    t.integer "num_recipients"
    t.integer "entry_id"
    t.string "sender_hash", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "document_number", collation: "utf8_general_ci"
  end

  create_table "entry_page_views", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.datetime "created_at"
    t.string "remote_ip", collation: "utf8_general_ci"
    t.text "raw_referer", size: :medium, collation: "utf8_general_ci"
    t.index ["created_at"], name: "index_entry_page_views_on_created_at"
    t.index ["entry_id"], name: "index_entry_page_views_on_entry_id"
  end

  create_table "entry_page_views_archive", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "entry_id"
    t.datetime "created_at"
    t.string "remote_ip"
    t.text "raw_referer", size: :medium
    t.index ["created_at"], name: "index_entry_page_views_on_created_at"
    t.index ["entry_id"], name: "index_entry_page_views_on_entry_id"
  end

  create_table "entry_regulation_id_numbers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.string "regulation_id_number", collation: "utf8_general_ci"
    t.index ["entry_id", "regulation_id_number"], name: "index"
    t.index ["regulation_id_number", "entry_id"], name: "rin_then_entry"
  end

  create_table "events", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.date "date"
    t.string "title", collation: "utf8_general_ci"
    t.integer "place_id"
    t.boolean "remote_call_in_available"
    t.string "event_type", collation: "utf8_general_ci"
    t.boolean "delta", default: true, null: false
    t.index ["delta"], name: "index_events_on_delta"
    t.index ["entry_id"], name: "index_events_on_entry_id"
    t.index ["event_type", "entry_id", "date"], name: "index_events_on_event_type_and_entry_id_and_date"
    t.index ["event_type", "entry_id", "place_id"], name: "index_events_on_event_type_and_entry_id_and_place_id"
    t.index ["event_type", "place_id", "entry_id"], name: "index_events_on_event_type_and_place_id_and_entry_id"
  end

  create_table "fr_index_agency_statuses", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "year"
    t.integer "agency_id"
    t.date "last_completed_issue"
    t.integer "needs_attention_count"
    t.date "oldest_issue_needing_attention"
    t.date "last_published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["year", "agency_id"], name: "index_fr_index_agency_statuses_on_year_and_agency_id"
  end

  create_table "generated_files", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "parameters", collation: "latin1_swedish_ci"
    t.string "token", collation: "latin1_swedish_ci"
    t.datetime "processing_began_at"
    t.datetime "processing_completed_at"
    t.string "attachment_file_name", collation: "latin1_swedish_ci"
    t.string "attachment_file_type", collation: "latin1_swedish_ci"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "total_document_count"
    t.integer "processed_document_count"
  end

  create_table "gpo_graphic_packages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "graphic_identifier", collation: "utf8_general_ci"
    t.string "package_identifier", collation: "utf8_general_ci"
    t.date "package_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["graphic_identifier"], name: "index_gpo_graphic_packages_on_graphic_identifier"
    t.index ["package_date"], name: "index_gpo_graphic_packages_on_package_date"
    t.index ["package_identifier"], name: "index_gpo_graphic_packages_on_package_identifier"
  end

  create_table "gpo_graphic_usages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "identifier", collation: "utf8_general_ci"
    t.string "document_number", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "xml_identifier", collation: "utf8_general_ci"
    t.index ["document_number", "identifier"], name: "index_gpo_graphic_usages_on_document_number_and_identifier", unique: true
    t.index ["document_number", "xml_identifier"], name: "index_gpo_graphic_usages_on_document_number_and_xml_identifier"
    t.index ["identifier", "document_number"], name: "index_gpo_graphic_usages_on_identifier_and_document_number"
    t.index ["xml_identifier", "document_number"], name: "index_gpo_graphic_usages_on_xml_identifier_and_document_number"
  end

  create_table "gpo_graphics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "identifier", collation: "utf8_general_ci"
    t.string "graphic_file_name", collation: "utf8_general_ci"
    t.string "graphic_content_type", collation: "utf8_general_ci"
    t.integer "graphic_file_size"
    t.datetime "graphic_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "package_identifier", collation: "utf8_general_ci"
    t.boolean "sourced_via_ecfr_dot_gov", default: false, null: false
    t.index ["graphic_file_name"], name: "index_gpo_graphics_on_graphic_file_name"
    t.index ["identifier"], name: "index_gpo_graphics_on_identifier", unique: true
  end

  create_table "graphic_styles", charset: "utf8mb4", force: :cascade do |t|
    t.integer "graphic_id"
    t.integer "height"
    t.integer "width"
    t.string "graphic_type"
    t.string "image_format"
    t.string "image_identifier"
    t.string "style_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "digest"
    t.index ["graphic_id"], name: "index_graphic_styles_on_graphic_id"
  end

  create_table "graphic_usages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "graphic_id"
    t.integer "entry_id"
    t.index ["entry_id", "graphic_id"], name: "index_graphic_usages_on_entry_id_and_graphic_id"
    t.index ["graphic_id", "entry_id"], name: "index_graphic_usages_on_graphic_id_and_entry_id"
  end

  create_table "graphics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "identifier", collation: "utf8_general_ci"
    t.integer "usage_count", default: 0, null: false
    t.string "graphic_file_name", collation: "utf8_general_ci"
    t.string "graphic_content_type", collation: "utf8_general_ci"
    t.integer "graphic_file_size"
    t.datetime "graphic_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "inverted"
    t.index ["identifier"], name: "index_graphics_on_identifier", unique: true
  end

  create_table "image_usages", charset: "utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "document_number"
    t.string "xml_identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_number", "identifier"], name: "index_image_usages_on_document_number_and_identifier", unique: true
  end

  create_table "image_variants", charset: "utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "style"
    t.string "image_file_name"
    t.integer "image_height"
    t.string "image_sha"
    t.integer "image_size"
    t.integer "image_width"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_content_type"
    t.index ["identifier", "style"], name: "index_image_variants_on_identifier_and_style", unique: true
  end

  create_table "images", charset: "utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "image_file_name"
    t.integer "image_height"
    t.string "image_sha"
    t.integer "image_size"
    t.integer "image_width"
    t.datetime "made_public_at"
    t.integer "source_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_content_type"
    t.string "error"
    t.index ["identifier"], name: "index_images_on_identifier", unique: true
  end

  create_table "issue_approvals", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "publication_date"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["publication_date"], name: "index_issue_approvals_on_publication_date"
  end

  create_table "issue_parts", charset: "utf8mb4", force: :cascade do |t|
    t.integer "issue_id"
    t.integer "start_page"
    t.integer "end_page"
    t.string "title"
    t.string "initial_document_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_issue_parts_on_issue_id"
  end

  create_table "issues", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "publication_date"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "frontmatter_page_count"
    t.integer "backmatter_page_count"
    t.integer "volume"
    t.integer "number"
    t.integer "rule_count"
    t.integer "proposed_rule_count"
    t.integer "notice_count"
    t.integer "presidential_document_count"
    t.integer "unknown_document_count"
    t.integer "correction_count"
    t.integer "rule_page_count"
    t.integer "proposed_rule_page_count"
    t.integer "notice_page_count"
    t.integer "presidential_document_page_count"
    t.integer "unknown_document_page_count"
    t.integer "correction_page_count"
    t.integer "blank_page_count"
    t.integer "start_page"
    t.integer "end_page"
    t.string "toc_note_title"
    t.text "toc_note_text"
    t.boolean "toc_note_active", default: false
    t.integer "correction_granule_class_count"
    t.integer "correction_granule_class_page_count"
  end

  create_table "lede_photos", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "credit", collation: "utf8_general_ci"
    t.string "credit_url", collation: "utf8_general_ci"
    t.string "photo_file_name", collation: "utf8_general_ci"
    t.string "photo_content_type", collation: "utf8_general_ci"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "url", collation: "utf8_general_ci"
    t.integer "crop_width"
    t.integer "crop_height"
    t.integer "crop_x"
    t.integer "crop_y"
  end

  create_table "pil_agency_letters", charset: "utf8mb4", force: :cascade do |t|
    t.integer "public_inspection_document_id"
    t.string "file_file_name"
    t.string "file_content_type"
    t.bigint "file_file_size"
    t.datetime "file_updated_at"
    t.string "title"
    t.index ["public_inspection_document_id"], name: "index_pil_agency_letters_on_public_inspection_document_id"
  end

  create_table "place_determinations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.integer "place_id"
    t.string "string", collation: "utf8_general_ci"
    t.string "context", collation: "utf8_general_ci"
    t.integer "confidence"
    t.float "relevance_score"
    t.index ["entry_id", "confidence", "place_id"], name: "index_place_determinations_on_entry_id_and_place_id"
    t.index ["place_id", "confidence", "entry_id"], name: "index_place_determinations_on_place_id_and_entry_id"
  end

  create_table "places", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.string "place_type", collation: "utf8_general_ci"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "open_calais_guid", limit: 100
    t.index ["open_calais_guid"], name: "index_places_on_open_calais_guid", unique: true
  end

  create_table "public_inspection_documents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "document_number", collation: "utf8_general_ci"
    t.string "granule_class", collation: "utf8_general_ci"
    t.datetime "filed_at"
    t.date "publication_date"
    t.boolean "special_filing", default: false, null: false
    t.string "pdf_file_name", collation: "utf8_general_ci"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.text "editorial_note", size: :medium, collation: "utf8_general_ci"
    t.string "document_file_path", collation: "utf8_general_ci"
    t.datetime "raw_text_updated_at"
    t.integer "num_pages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "entry_id"
    t.string "subject_1", limit: 2000
    t.string "subject_2", limit: 2000
    t.string "subject_3", limit: 2000
    t.string "pdf_url", collation: "utf8_general_ci"
    t.string "category", collation: "utf8_general_ci"
    t.datetime "update_pil_at"
    t.datetime "subscriptions_enqueued_at"
    t.integer "universal_analytics_page_views"
    t.integer "historical_page_view_count"
    t.index ["document_number"], name: "index_public_inspection_documents_on_document_number"
    t.index ["entry_id"], name: "index_public_inspection_documents_on_entry_id"
    t.index ["publication_date"], name: "index_public_inspection_documents_on_publication_date"
  end

  create_table "public_inspection_issues", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "publication_date"
    t.datetime "published_at"
    t.datetime "special_filings_updated_at"
    t.datetime "regular_filings_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "special_filing_documents_count"
    t.integer "special_filing_agencies_count"
    t.integer "regular_filing_documents_count"
    t.integer "regular_filing_agencies_count"
  end

  create_table "public_inspection_postings", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "issue_id"
    t.integer "document_id"
    t.index ["document_id"], name: "index_public_inspection_postings_on_document_id"
    t.index ["issue_id", "document_id"], name: "index_public_inspection_postings_on_issue_id_and_document_id"
  end

  create_table "regs_dot_gov_dockets", id: :string, default: "", charset: "latin1", force: :cascade do |t|
    t.string "regulation_id_number"
    t.integer "comments_count"
    t.integer "docket_documents_count"
    t.string "title", limit: 1000
    t.text "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "agency_id"
  end

  create_table "regs_dot_gov_documents", charset: "utf8", force: :cascade do |t|
    t.boolean "allow_late_comments"
    t.integer "comment_count"
    t.date "comment_end_date"
    t.date "comment_start_date"
    t.string "deleted_at"
    t.string "docket_id"
    t.string "regulations_dot_gov_document_id"
    t.string "federal_register_document_number"
    t.string "original_federal_register_document_number"
    t.string "regulations_dot_gov_object_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "regulations_dot_gov_open_for_comment"
    t.datetime "allow_late_comments_updated_at"
    t.index ["docket_id"], name: "index_regs_dot_gov_documents_on_docket_id"
    t.index ["federal_register_document_number", "deleted_at"], name: "[:document_number_deleted_at]"
    t.index ["regulations_dot_gov_document_id"], name: "index_regs_dot_gov_documents_on_regulations_dot_gov_document_id"
  end

  create_table "regs_dot_gov_supporting_documents", id: :string, charset: "latin1", force: :cascade do |t|
    t.string "docket_id"
    t.string "title", limit: 1000
    t.text "metadata"
    t.index ["docket_id"], name: "index_regs_dot_gov_supporting_documents_on_docket_id"
  end

  create_table "regulatory_plan_events", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "regulatory_plan_id"
    t.string "date", collation: "utf8_general_ci"
    t.string "action", collation: "utf8_general_ci"
    t.string "fr_citation", collation: "utf8_general_ci"
    t.index ["regulatory_plan_id"], name: "index_regulatory_plan_events_on_regulatory_plan_id"
  end

  create_table "regulatory_plans", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "regulation_id_number", collation: "utf8_general_ci"
    t.string "issue", collation: "utf8_general_ci"
    t.text "title", size: :medium, collation: "utf8_general_ci"
    t.text "abstract", size: :medium, collation: "utf8_general_ci"
    t.string "priority_category", collation: "utf8_general_ci"
    t.boolean "delta", default: true, null: false
    t.boolean "current"
    t.index ["current", "regulation_id_number"], name: "index_regulatory_plans_on_current_and_regulation_id_number"
    t.index ["delta"], name: "index_regulatory_plans_on_delta"
    t.index ["issue", "regulation_id_number"], name: "index_regulatory_plans_on_issue_and_regulation_id_number"
    t.index ["regulation_id_number", "issue"], name: "index_regulatory_plans_on_regulation_id_number_and_issue"
  end

  create_table "regulatory_plans_small_entities", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "regulatory_plan_id"
    t.integer "small_entity_id"
    t.index ["regulatory_plan_id", "small_entity_id"], name: "reg_then_entity"
  end

  create_table "reprocessed_issues", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "issue_id"
    t.string "status", limit: 1000
    t.string "message", limit: 1000
    t.text "diff", size: :medium
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "html_diff", size: :long
    t.index ["user_id"], name: "index_reprocessed_issues_on_user_id"
  end

  create_table "section_assignments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.integer "section_id"
    t.index ["entry_id", "section_id"], name: "index_section_assignments_on_entry_id_and_section_id"
    t.index ["section_id", "entry_id"], name: "index_section_assignments_on_section_id_and_entry_id"
  end

  create_table "section_highlights", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "section_id"
    t.integer "entry_id"
    t.integer "position"
    t.date "publication_date"
    t.index ["section_id", "entry_id"], name: "index_section_highlights_on_section_id_and_entry_id"
  end

  create_table "sections", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", collation: "utf8_general_ci"
    t.string "slug", collation: "utf8_general_ci"
    t.integer "position"
    t.text "description", size: :medium, collation: "utf8_general_ci"
    t.text "relevant_cfr_sections", size: :medium, collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "site_notifications", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "identifier", collation: "utf8_general_ci"
    t.string "notification_type", collation: "utf8_general_ci"
    t.text "description", collation: "utf8_general_ci"
    t.boolean "active"
  end

  create_table "small_entities", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
  end

  create_table "system_of_record_assignments", id: false, charset: "utf8", force: :cascade do |t|
    t.bigint "system_of_record_id"
    t.bigint "entry_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_system_of_record_assignments_on_entry_id"
    t.index ["system_of_record_id"], name: "index_system_of_record_assignments_on_system_of_record_id"
  end

  create_table "system_of_records", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "topic_assignments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "topics_topic_name_id"
    t.index ["entry_id", "topic_id"], name: "index_topic_assignments_on_entry_id_and_topic_id"
    t.index ["topic_id", "entry_id"], name: "index_topic_assignments_on_topic_id_and_entry_id"
    t.index ["topics_topic_name_id"], name: "index_topic_assignments_on_topics_topic_name_id"
  end

  create_table "topic_name_assignments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "entry_id"
    t.integer "topic_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entry_id", "topic_name_id"], name: "index_topic_name_assignments_on_entry_id_and_topic_name_id"
    t.index ["topic_name_id", "entry_id"], name: "index_topic_name_assignments_on_topic_name_id_and_entry_id"
  end

  create_table "topic_names", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.boolean "void", default: false
    t.integer "entries_count", default: 0
    t.integer "topics_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_topic_names_on_name"
    t.index ["void", "topics_count"], name: "index_topic_names_on_void_and_topics_count"
  end

  create_table "topics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", collation: "utf8_general_ci"
    t.integer "entries_count", default: 0
    t.text "related_topics_cache", collation: "utf8_general_ci"
    t.text "related_agencies_cache", collation: "utf8_general_ci"
    t.index ["entries_count"], name: "index_topics_on_entries_count"
    t.index ["name"], name: "index_topics_on_name"
    t.index ["slug", "id"], name: "index_topics_on_group_name_and_id"
  end

  create_table "topics_topic_names", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "topic_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["topic_id", "topic_name_id"], name: "index_topics_topic_names_on_topic_id_and_topic_name_id"
    t.index ["topic_name_id", "topic_id"], name: "index_topics_topic_names_on_topic_name_id_and_topic_id"
  end

  create_table "url_references", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "url_id"
    t.integer "entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entry_id"], name: "index_url_references_on_entry_id"
    t.index ["url_id"], name: "index_url_references_on_url_id"
  end

  create_table "urls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.string "type", collation: "utf8_general_ci"
    t.string "content_type", collation: "utf8_general_ci"
    t.integer "response_code"
    t.float "content_length"
    t.string "title", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_urls_on_name"
    t.index ["type"], name: "index_urls_on_type"
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", null: false, collation: "utf8_general_ci"
    t.string "crypted_password", collation: "utf8_general_ci"
    t.string "password_salt", collation: "utf8_general_ci"
    t.string "persistence_token", null: false, collation: "utf8_general_ci"
    t.string "single_access_token", null: false, collation: "utf8_general_ci"
    t.string "perishable_token", null: false, collation: "utf8_general_ci"
    t.integer "login_count", default: 0, null: false
    t.integer "failed_login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip", collation: "utf8_general_ci"
    t.string "last_login_ip", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.string "first_name", collation: "utf8_general_ci"
    t.string "last_name", collation: "utf8_general_ci"
    t.boolean "active", default: true
  end

end

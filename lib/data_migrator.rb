class DataMigrator
  def source_db
    'fr2_production'
  end

  def destination_db
    'federal_register_api_core'
  end

  def copy_curated
    copy_entry_columns(
      :curated_title,
      :curated_abstract,
    )
    copy_table(:issue_approvals)
  end

  def copy_core_data
    #copy_page_views_archive
    copy_eo_details
    copy_users
    copy_fr_index
    copy_regulatory_plan
    copy_regulations_dot_gov_data
    copy_agencies
    copy_topics
    copy_gpo_graphics
    copy_canned_searches
    copy_reprocessing_data
  end

  def copy_dynamic_data
    copy_public_inspection
    copy_page_views
  end

  def copy_fr_index
    copy_table(:fr_index_agency_statuses)
    copy_table(:dictionary_words)
    copy_table(:generated_files)

    copy_entry_columns(:fr_index_subject, :fr_index_doc)
  end

  def copy_page_views_archive
    copy_table(:entry_page_views_archive)
  end

  def copy_eo_details
    copy_entry_columns(
      :executive_order_number,
      :signing_date,
      :executive_order_notes,
      :granule_class,
      :presidential_document_type_id,
      :citation,
      :where => "source_entries.executive_order_number > 0"
    )
  end

  def copy_users
    copy_table(:users)
  end

  def copy_regulatory_plan
    copy_table(:regulatory_plan_events)
    copy_table(:regulatory_plans)
    copy_table(:regulatory_plans_small_entities)
    copy_entry_columns(:significant)
  end

  def copy_regulations_dot_gov_data
    copy_table(:dockets)
    copy_table(:docket_documents)
    copy_entry_columns(
      :regulationsdotgov_url,
      :comment_url,
      :checked_regulationsdotgov_at,
      :regulations_dot_gov_docket_id,
      :comment_url_override,
    )
  end

  def copy_gpo_graphics
    copy_table(:gpo_graphic_packages)
    copy_table(:gpo_graphic_usages)
    copy_table(:gpo_graphics)
  end

  def copy_canned_searches
    copy_table(:canned_searches)
  end

  def copy_agencies
    copy_table(:agencies)
    execute <<-SQL
      UPDATE #{destination_db}.agency_names AS destination_agency_names,
        #{source_db}.agency_names AS source_agency_names
      SET destination_agency_names.agency_id = source_agency_names.agency_id
      WHERE destination_agency_names.name = source_agency_names.name
    SQL

    log("Recalculating Agency Assignments") do
      AgencyAssignment.recalculate!
    end
  end

  def copy_topics
    copy_table(:topics)

    # replace contents of topics_topic_names
    truncate_table(:topics_topic_names)
    execute <<-SQL
      INSERT INTO topics_topic_names (topic_id, topic_name_id, created_at, updated_at, creator_id, updater_id)
      SELECT topics_topic_names.topic_id,
        destination_topic_names.id,
        topics_topic_names.created_at,
        topics_topic_names.updated_at,
        topics_topic_names.creator_id,
        topics_topic_names.updater_id
      FROM #{source_db}.topics_topic_names
      JOIN #{source_db}.topic_names AS source_topic_names
        ON source_topic_names.id = topics_topic_names.topic_name_id
      JOIN #{destination_db}.topic_names AS destination_topic_names
        ON destination_topic_names.name = source_topic_names.name
    SQL

    # replace content of topic_assignments
    truncate_table(:topic_assignments)
    execute <<-SQL
      INSERT INTO topic_assignments (topic_id, entry_id, topics_topic_name_id)
      SELECT topics_topic_names.topic_id,
        topic_name_assignments.entry_id,
        topics_topic_names.id
      FROM #{destination_db}.topic_name_assignments
      JOIN #{destination_db}.topics_topic_names
        ON topics_topic_names.topic_name_id = topic_name_assignments.topic_name_id
    SQL
  end

  def copy_public_inspection
    copy_table(:public_inspection_documents)
    copy_table(:public_inspection_issues)
    copy_table(:public_inspection_postings)

    execute <<-SQL
      UPDATE #{destination_db}.public_inspection_documents
      SET entry_id = NULL
    SQL

    execute <<-SQL
      UPDATE #{destination_db}.public_inspection_documents, #{destination_db}.entries
      SET public_inspection_documents.entry_id = entries.id
      WHERE public_inspection_documents.document_number = entries.document_number
    SQL

    PublicInspectionDocument.find_each(:conditions => {:entry_id => nil}).each do |pi_doc|
      pi_doc.entry = Entry.find_by_document_number(pi_doc.document_number)
      pi_doc.save(validate: false)
    end
  end

  def copy_page_views
    copy_table(:entry_page_views)
  end

  def copy_reprocessing_data
    copy_table(:reprocessed_issues)
  end

  private

  def log(message)
    indent = message.scan(/^[ \t]*(?=\S)/).min.try(:size) || 0
    message = message.gsub(/^[ \t]{#{indent}}/, '').rstrip
    puts message

    time = Benchmark.measure do
      yield
    end.real
    puts "\t#{time}\n\n"
  end

  def execute(sql)
    log(sql) do
      Entry.connection.execute(sql)
    end
  end

  def truncate_table(table_name)
    execute <<-SQL
      TRUNCATE #{destination_db}.#{table_name}
    SQL
  end

  def copy_table(table_name)
    truncate_table(table_name)

    execute <<-SQL
      INSERT INTO #{destination_db}.#{table_name}
      SELECT #{table_name}.*
      FROM #{source_db}.#{table_name}
    SQL
  end

  def copy_entry_columns(*columns)
    options = columns.extract_options!

    execute <<-SQL
      UPDATE #{destination_db}.entries AS destination_entries, #{source_db}.entries AS source_entries
      SET #{columns.map{|col| "destination_entries.#{col} = source_entries.#{col}"}.join(', ')}
      WHERE destination_entries.document_number = source_entries.document_number
      #{"AND #{options[:where]}" if options[:where]}
    SQL
  end
end

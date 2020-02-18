ThinkingSphinx::Index.define :entry, :with => :active_record, :delta => ThinkingSphinx::Deltas::ManualDelta do

    set_property :sql_query_killlist => <<-SQL.gsub(/\s+/, ' ')
      SELECT entries.id * #{ThinkingSphinx::Configuration.instance.indices.count} + #{ThinkingSphinx::Configuration.instance.indices.reject(&:delta?).find{|x| x.reference == :entry}.offset}
      FROM entries
      WHERE delta = 1
    SQL

    # fields
    indexes title
    indexes abstract
    indexes "CONCAT('#{FileSystemPathManager.data_file_path}/documents/full_text/raw/', document_file_path, '.txt')", :as => :full_text, :file => true
    indexes "GROUP_CONCAT(DISTINCT IFNULL(`entry_regulation_id_numbers`.`regulation_id_number`, '0') SEPARATOR ' ')", :as =>  :regulation_id_number
    join entry_regulation_id_numbers

    indexes <<-SQL, :as => :docket_id
      (
        SELECT GROUP_CONCAT(DISTINCT docket_numbers.number SEPARATOR ' ')
        FROM docket_numbers
        WHERE docket_numbers.assignable_id = entries.id
          AND docket_numbers.assignable_type = 'Entry'
      )
    SQL

    has "CRC32(document_number)", :as => :document_number, :type => :integer
    has "CRC32(IF(granule_class = 'SUNSHINE', 'NOTICE', granule_class))", :as => :type, :type => :integer
    has presidential_document_type_id

    has "DATE_ADD(publication_date, INTERVAL(-WEEKDAY(publication_date)) DAY)", as: :publication_date_week, type: :timestamp
    has "DATE_ADD(DATE_ADD(LAST_DAY(publication_date),interval 1 DAY),interval -1 MONTH)", as: :publication_date_month, type: :timestamp
    has "MAKEDATE(YEAR(publication_date), 1) + INTERVAL QUARTER(publication_date) QUARTER - INTERVAL 1 QUARTER", as: :publication_date_quarter, type: :timestamp
    has "MAKEDATE(YEAR(publication_date),1)", as: :publication_date_year, type: :timestamp
    has publication_date
    has "IF(granule_class = 'PRESDOCU', IFNULL(signing_date, publication_date), NULL)", as: :signing_date, type: :timestamp

    has "IF(granule_class = 'PRESDOCU', INTERVAL(DATE_FORMAT(IFNULL(signing_date,DATE_SUB(publication_date, INTERVAL 3 DAY)), '%Y%m%d'),#{President.all.map{|p| p.starts_on.strftime("%Y%m%d")}.join(', ')}), NULL)", :as => :president_id, :type => :integer
    has "IF(granule_class = 'CORRECT' OR correction_of_id IS NOT NULL OR (presidential_document_type_id = 2 AND (executive_order_number = 0 or executive_order_number IS NULL)), 1, 0)", :as => :correction, :type => :boolean
    has start_page
    has executive_order_number
    has proclamation_number

    has <<-SQL, :as => :cfr_affected_parts, :multi => true, :type => :integer
      (
        SELECT GROUP_CONCAT(DISTINCT title * #{EntrySearch::CFR::TITLE_MULTIPLIER} + part SEPARATOR ',')
        FROM entry_cfr_references
        WHERE entry_id = entries.id
      )
    SQL
    has <<-SQL, :as => :agency_ids, :multi => true, :type => :integer
      (
        SELECT GROUP_CONCAT(DISTINCT agency_id SEPARATOR ',')
        FROM agency_assignments
        WHERE assignable_id = entries.id
          AND assignable_type = 'Entry'
          AND agency_id IS NOT NULL
      )
    SQL
    has <<-SQL, :as => :topic_ids, :multi => true, :type => :integer
      (
        SELECT GROUP_CONCAT(DISTINCT topic_id SEPARATOR ',')
        FROM topic_assignments
        WHERE entry_id = entries.id
          AND topic_id IS NOT NULL
      )
    SQL
    has <<-SQL, :as => :section_ids, :multi => true, :type => :integer
      (
        SELECT GROUP_CONCAT(DISTINCT section_id SEPARATOR ',')
        FROM section_assignments
        WHERE entry_id = entries.id
          AND section_id IS NOT NULL
      )
    SQL
    has <<-SQL, :as => :place_ids, :multi => true, :type => :integer
      (
        SELECT GROUP_CONCAT(DISTINCT IFNULL(place_id, '0') SEPARATOR ',')
        FROM place_determinations
        WHERE entry_id = entries.id
          AND place_id IS NOT NULL
      )
    SQL
    has <<-SQL, :as => :cited_entry_ids, :multi => true, :type => :integer
      (
        SELECT GROUP_CONCAT(DISTINCT cited_entry_id SEPARATOR ',')
        FROM citations
        WHERE source_entry_id = entries.id
          AND cited_entry_id IS NOT NULL
      )
    SQL
    has effective_date(:date), :as => :effective_date
    has comments_close_date(:date), :as => :comment_date

    has "IF(comment_url != '', 1, 0)", :as => :accepting_comments_on_regulations_dot_gov, :type => :boolean

    has <<-SQL, :as => :small_entity_ids, :type => :integer
      (
        SELECT GROUP_CONCAT(DISTINCT IFNULL(regulatory_plans_small_entities.small_entity_id,0) SEPARATOR ',')
        FROM entry_regulation_id_numbers
        LEFT OUTER JOIN regulatory_plans ON regulatory_plans.regulation_id_number = entry_regulation_id_numbers.regulation_id_number AND regulatory_plans.current = 1
        LEFT OUTER JOIN regulatory_plans_small_entities ON regulatory_plans_small_entities.regulatory_plan_id = regulatory_plans.id
        WHERE entry_id = entries.id
      )
    SQL

    has "SUM(IF(regulatory_plans.priority_category IN (#{RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES.map{|c| "'#{c}'"}.join(',')}),1,0)) > 0",
      :as => :significant,
      :type => :boolean
    join regulatory_plans

    set_property :field_weights => {
      "title" => 100,
      "abstract" => 50,
      "full_text" => 25,
      "agency_name" => 10
    }

  # this line must appear after the define_index block
  # include ThinkingSphinx::Deltas::ManualDelta::ActiveRecord
end

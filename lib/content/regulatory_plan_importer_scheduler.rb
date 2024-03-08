module Content
  class RegulatoryPlanImporterScheduler

    def self.reimport_currently_stored_issue
      start_time = Time.current
      # Reimport all of currently-stored issue
      currently_stored_issue = RegulatoryPlan.maximum(:issue)
      Content::RegulatoryPlanImporter.
        import_all_by_publication_date(currently_stored_issue)
      # Recalculate current regulatory plans
      entry_ids = Content::RegulatoryPlanImporter.recalculate_current(
        calculate_entry_ids_for_reindex: true
      )
      # Reindex ES
      Entry.
        where(id: entry_ids).
        pre_joined_for_es_indexing.
        find_in_batches(batch_size: 500) do |entry_batch|
          Entry.bulk_index(entry_batch, refresh: false)
        end
      notify_slack!("#{Rails.env.upcase}: Reimport of #{currently_stored_issue} unified agenda complete.  It took #{(Time.current - start_time).to_i/60} minutes.")
    end

    def perform
      reindex = false
      while next_issue_available?
        reindex = true
        Content::RegulatoryPlanImporter.import_all_by_publication_date(next_issue)
        Content::RegulatoryPlanImporter.recalculate_current
      end

      if reindex
        Honeybadger.notify("Update: Reindexing all elasticsearch entries--detected a semi-annual Unified Agenda update.")
        ElasticsearchIndexer.reindex_entries
      end
    end

    private

    def self.notify_slack!(message)
      notifier = Slack::Notifier.new Rails.application.credentials.dig(:slack, :webhook_url) do
        defaults channel: "#federalregister",
                 username: "Unified Agenda Reimport Notifier"
      end
      notifier.ping message
    end

    def next_issue_available?
      response = Faraday.head(unified_agenda_url)
      response.status == 200
    end

    def unified_agenda_url
      "https://www.reginfo.gov/public/do/eAgendaMain?operation=OPERATION_GET_AGENCY_RULE_LIST&currentPubId=#{next_issue}&agencyCd=0000"
    end

    def next_issue
      most_recent_issue = RegulatoryPlan.maximum(:issue)
      year = most_recent_issue.first(4).to_i
      spring_or_fall = most_recent_issue.last(2)
      if spring_or_fall == '04'
        "#{year}10"
      elsif spring_or_fall == '10'
        "#{year+1}04"
      else
        raise NotImplementedError
      end
    end

  end
end

module Content
  class RegulatoryPlanImporterScheduler

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

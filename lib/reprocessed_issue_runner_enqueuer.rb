class ReprocessedIssueRunnerEnqueuer
  extend Memoist

  def initialize(current_issue_only: false)
    @current_issue_only = current_issue_only
  end

  def perform
    packages_for_processing.
      each do |package|
        last_modified = Time.parse(package.lastModified)
        issue_date    = Date.parse(package.dateIssued)
        reprocessed_issue = ReprocessedIssue.
          joins(:issue).
          where(issue: {publication_date: issue_date}).
          where("reprocessed_issues.created_at > ?", last_modified.to_s).
          first

        if reprocessed_issue || already_enqueued_dates.include?(issue_date.to_s(:iso))
          puts "#{package.dateIssued} issue already reprocessed or is already enqueued for reprocessing"
          next
        else
          puts "reprocessing #{package.dateIssued}"
          if issue_date == current_issue.publication_date
            queue = 'high_priority'
          else
            queue = 'reimport'
          end

          Sidekiq::Client.push(
            'args'  => [issue_date.to_s(:iso)],
            'class' => ReprocessedIssueRunner,
            'queue' => queue,
            'retry' => false
          )
        end
      end
  end

  private

  attr_reader :current_issue_only

  def current_issue
    Issue.current
  end
  memoize :current_issue

  def packages_for_processing
    packages.
      select do |package|
        if current_issue_only
          current_issue.publication_date.to_s(:iso) == package.dateIssued
        else
          current_issue.publication_date.to_s(:iso) != package.dateIssued
        end
      end
  end

  def packages
    GovInfoClient.last_modified_fr_collections(last_modified_start_date: Date.current - 2.days)
  end

  def already_enqueued_dates
    already_enqueued_dates = Set.new
    Sidekiq::Queue.new('reimport').each do |job|
      if job.klass == 'ReprocessedIssueRunner'
        already_enqueued_dates << job.args.first
      end
    end
    already_enqueued_dates
  end
  memoize :already_enqueued_dates

end

class RakeTaskDateEnqueuer
  @queue = :api_core

  def self.perform(task, date, args=nil)
    Rake.add_rakelib 'lib/tasks'

    ENV['DATE'] = date
    Rake::Task[task].reenable

    if args
      Rake::Task[task].invoke(*args.split(','))
    else
      Rake::Task[task].invoke
    end
  end
end

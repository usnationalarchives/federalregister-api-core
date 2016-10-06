class RakeTaskDateEnqueuer
  @queue = :default

  def self.perform(task, date, args=nil)
    load File.join(Rails.root, 'Rakefile')

    ENV['DATE'] = date
    Rake::Task[task].reenable

    if args
      Rake::Task[task].invoke(*args.split(','))
    else
      Rake::Task[task].invoke
    end
  end
end

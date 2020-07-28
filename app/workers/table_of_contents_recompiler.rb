class TableOfContentsRecompiler
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reimport, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!

    Content::TableOfContentsCompiler.perform(date)
  end
end

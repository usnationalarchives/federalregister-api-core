class PlaceDeterminerEnqueuer

  def initialize(est_remaining_api_calls)
    @est_remaining_api_calls = est_remaining_api_calls
  end

  def perform
    entity_ids.each do |entry_id|
      Sidekiq::Client.enqueue(PlaceDeterminer, entry_id)
    end
  end

  private

  attr_reader :est_remaining_api_calls

  def entity_ids
    Entry.
      where.not(abstract: nil).
      where.not(raw_text_updated_at: nil).
      where(places_determined_at: nil).
      order(publication_date: :desc).
      limit(est_remaining_api_calls).
      pluck(:id)
  end

end

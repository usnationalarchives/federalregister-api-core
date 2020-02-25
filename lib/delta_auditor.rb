class DeltaAuditor
  class DeltaDifferenceError < StandardError; end

  def self.perform
    entry_delta_count  = Entry.where(delta: true).count
    entry_change_count = EntryChange.joins(:entry).count

    if entry_delta_count != entry_change_count
      raise DeltaDifferenceError.new("Entry Delta Count: #{entry_delta_count} | EntryChange Count: #{entry_change_count}")
    end
  end

end

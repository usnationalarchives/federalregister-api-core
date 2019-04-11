class ThinkingSphinx::Deltas::ManualDelta::ActiveRecord
  private
  # Only mark record to be added to the delta index if it is newly created.
  def should_toggle_delta?
    self.new_record?
  end
end
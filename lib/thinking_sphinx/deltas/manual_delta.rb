# don't reindex the delta index; we'll do that manually...
class ThinkingSphinx::Deltas::ManualDelta < ThinkingSphinx::Deltas::DefaultDelta

  # Invoked via a before_save callback. The default behaviour is to set the
  # delta column to true.
  def toggle(instance)
    instance.new_record?
  end

  # Invoked via an after_commit callback. The default behaviour is to check
  # whether the delta column is set to true. If this method returns true, the
  # indexer is fired.
  def toggled?(instance)
    return false
  end

end

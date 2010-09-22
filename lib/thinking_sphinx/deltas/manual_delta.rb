# don't reindex the delta index; we'll do that manually...
class ThinkingSphinx::Deltas::ManualDelta < ThinkingSphinx::Deltas::DefaultDelta
  # Do nothing!
  def index(model, instance = nil)
    return true
  end
end
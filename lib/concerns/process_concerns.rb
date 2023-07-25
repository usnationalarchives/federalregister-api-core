module ProcessConcerns
  def maxrss
    if /darwin/.match?(RUBY_PLATFORM)
      Process.getrusage.maxrss / 1.kilobyte # macOS returns bytes
    else
      Process.getrusage.maxrss # linux returns kilobytes
    end
  end
end

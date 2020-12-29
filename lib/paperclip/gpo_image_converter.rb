class Paperclip::GpoImageConverter < Paperclip::Thumbnail
  extend Memoist
  # GPO images appear to come in at least 2 densities - 300 and 660
  def source_file_options
    options = @source_file_options
    options << "-density"
    options << density
    options << resize_options
    options
  end

  private

  def density
    if sourced_via_ecfr_dot_gov_options?
      300
    else
      Paperclip.run("identify -format '%x' #{File.expand_path(@file.path)}")
    end
  end
  memoize :density

  def resize_options
    if sourced_via_ecfr_dot_gov_options?
      dimensions = Paperclip.run("identify -format '%wx%h' #{File.expand_path(@file.path)}")
      " -resize #{dimensions}"
    end
  end

  def sourced_via_ecfr_dot_gov_options?
    attachment.instance.sourced_via_ecfr_dot_gov && (options.fetch(:style) == :original_png)
  end
end

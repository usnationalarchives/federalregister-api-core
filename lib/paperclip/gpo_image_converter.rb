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

  MAX_DESIRED_WIDTH_IN_PIXELS          = 756
  LINEAR_UPSCALING_THRESHOLD_IN_PIXELS = 351 #NOTE: This represents the threshold at which we will no longer upscale the image linearly.
  def resize_options
    if sourced_via_ecfr_dot_gov_options?
      dimensions    = Paperclip.run("identify -format '%wx%h' #{File.expand_path(@file.path)}")
      width, height = dimensions.split('x').map(&:to_i)

      if width > LINEAR_UPSCALING_THRESHOLD_IN_PIXELS
        scaled_dimensions = "#{MAX_DESIRED_WIDTH_IN_PIXELS}x#{(MAX_DESIRED_WIDTH_IN_PIXELS.to_f/width) * height}"
      else
        scaling_multiplier = MAX_DESIRED_WIDTH_IN_PIXELS.to_f / LINEAR_UPSCALING_THRESHOLD_IN_PIXELS
        scaled_dimensions = "#{width * scaling_multiplier}x#{height * scaling_multiplier}"
      end

      " -resize #{scaled_dimensions}"
    end
  end

  def sourced_via_ecfr_dot_gov_options?
    attachment.instance.sourced_via_ecfr_dot_gov && (options.fetch(:style) == :ecfr)
  end
end

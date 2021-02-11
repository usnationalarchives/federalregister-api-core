class Paperclip::GpoImageConverter < Paperclip::Thumbnail
  extend Memoist
  # GPO images appear to come in at least 2 densities - 300 and 660
  def source_file_options
    options = @source_file_options
    options << "-density"
    options << density
    if additional_options
      options << additional_options
    end
    if resize_options
      options << resize_options
    end
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
    if (paperclip_style == :medium) || (paperclip_style == :large)
      dimensions    = Paperclip.run("identify -format '%wx%h' #{File.expand_path(@file.path)}")
      width, height = dimensions.split('x').map(&:to_i)

      if width > full_page_pixel_width_in_print
        scaled_dimensions = "#{max_desired_pixel_width}x#{((max_desired_pixel_width.to_f/width) * height).round(0)}"
      else
        scaling_multiplier = max_desired_pixel_width.to_f / full_page_pixel_width_in_print
        scaled_dimensions = "#{(width * scaling_multiplier).round(0)}x#{(height * scaling_multiplier).round(0)}"
      end

      "-resize #{scaled_dimensions}"
    end
  end

  def additional_options
    if paperclip_style != :original_png
      " -monochrome -transparent white"
    end
  end

  def max_desired_pixel_width
    case paperclip_style
    when :medium
      574 #FR paragraph width: 574px
    when :large
      823 #eCFR top-level paragraph sidebar collapsed
    else
      raise NotImplementedError
    end
  end

  def full_page_pixel_width_in_print
    #NOTE: This represents the threshold at which we will no longer upscale the image linearly.
    case paperclip_style
    when :medium
      #TODO
    when :large
      351
    else
      raise NotImplementedError
    end
  end

  def sourced_via_ecfr_dot_gov_options?
    attachment.instance.sourced_via_ecfr_dot_gov && (options.fetch(:style) == :ecfr)
  end

  def paperclip_style
    options.fetch(:style)
  end

end

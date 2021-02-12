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

  ROUNDING_PRECISION = 0
  PRINT_PAGE_DPI     = 72
  def resize_options
    if (paperclip_style == :medium) || (paperclip_style == :large)
      dimensions                = Paperclip.run("identify -format '%wx%h' #{File.expand_path(@file.path)}")
      pixel_width, pixel_height = dimensions.split('x').map(&:to_i)
      width_in_inches           = (pixel_width.to_f/PRINT_PAGE_DPI) #NOTE: It appears that even if an image has a density that's not 72, we should use 72 as the factor for calculating the width of the image in inches e.g. images er16no17.186 (density of 600) and ep30no18.005 (density of 300)
      if width_in_inches > full_page_inches_width_in_print
        scaled_height     =  ((max_desired_pixel_width.to_f/pixel_width) * pixel_height).round(ROUNDING_PRECISION)
        scaled_dimensions = "#{max_desired_pixel_width}x#{scaled_height}"
      else
        scaled_width      = (width_in_inches/full_page_inches_width_in_print * max_desired_pixel_width).round(ROUNDING_PRECISION)
        scaled_height     = (scaled_width.to_f/pixel_width * pixel_height).round(ROUNDING_PRECISION)
        scaled_dimensions = "#{scaled_width}x#{scaled_height}"
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

  def full_page_inches_width_in_print
    full_page_pixel_width_in_print.to_f / 72
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

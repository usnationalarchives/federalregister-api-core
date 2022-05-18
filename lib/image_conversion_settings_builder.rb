# This class is modeled to replicate the logic in the Paperclip::GpoImageConverter processor
class ImageConversionSettingsBuilder
  extend Memoist

  def initialize(image_path, image_source, image_style)
    @image_path   = image_path
    @image_source = image_source
    @image_style  = image_style
  end

  def perform
    options = "" #formerly @source_file_options
    options << "-density #{density}"
    if image_style.apply_transparency_via_image_magick_setting
      options << " -monochrome -transparent white"
    end
    if image_style.apply_resize
      options << resize_options
    end
    options << compression_options
    options
  end

  private

  attr_reader :image_path, :image_source, :image_style

  def density
    if image_source.pre_assigned_density && image_style.permits_preassigned_density
      image_source.pre_assigned_density
    else
      Paperclip.run("identify -format '%x' #{image_path}")
    end
  end
  memoize :density

  ROUNDING_PRECISION = 0
  PRINT_PAGE_DPI     = 72
  def resize_options
    dimensions                = Paperclip.run("identify -format '%wx%h' #{File.expand_path(image_path)}")
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

    " -resize #{scaled_dimensions}"
  end

  def max_desired_pixel_width
    image_style.max_desired_pixel_width || (raise NotImplementedError)
  end

  def full_page_inches_width_in_print
    full_page_pixel_width_in_print.to_f / 72
  end

  def full_page_pixel_width_in_print
    #NOTE: This represents the threshold at which we will no longer upscale the image linearly.
    image_style.full_page_pixel_width_in_print || (raise NotImplementedError)
  end

  def compression_options
    " -colors 8" #NOTE: This appears to reduce PNG size by ~65% for ecfr.gov-sourced images.
  end

end

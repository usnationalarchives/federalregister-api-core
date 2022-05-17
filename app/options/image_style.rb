class ImageStyle < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      identifier: 'original_size',
      apply_resize: false,
      image_magick_operators: '-auto-orient -resize "100%" -strip -unsharp 0 -fuzz 10% -transparent white',
      permits_preassigned_density: false,
    },
    {
      identifier: 'medium', 
      apply_resize: true,
      full_page_pixel_width_in_print: 520,
      image_magick_operators: "-auto-orient -strip -unsharp 0",
      max_desired_pixel_width: 574, #FR paragraph width: 574px
      permits_preassigned_density: true,
    },
    {
      identifier: 'large',
      apply_resize: true,
      full_page_pixel_width_in_print: 351,
      image_magick_operators: "-auto-orient -strip -unsharp 0",
      max_desired_pixel_width: 823, #eCFR top-level paragraph sidebar collapsed
      permits_preassigned_density: true,
    },
  ]

end

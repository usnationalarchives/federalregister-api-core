module Paperclip
  # Handles thumbnailing images that are uploaded.
  class AutoInverter < Thumbnail
    # Modifies the command ImageMagick's +convert+ options to invert if necessary
    def transformation_command
      trans = super
      
      if attachment.instance.inverted.nil?
        attachment.instance.inverted = darkness > 0.6
      end
      
      if attachment.instance.inverted?
        trans << " -negate" if attachment.instance.inverted?
      end
      
      trans
    end
    
    private
      def darkness
        output = Paperclip.run("identify -format '%[mean],%[max]' #{File.expand_path(@file.path)}")
        mean, max = output.split(',')
        1 - (mean.to_f / max.to_f)
      end
  end
end
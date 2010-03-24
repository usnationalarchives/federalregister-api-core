module Paperclip
  # Handles thumbnailing images that are uploaded.
  class AutoInverter < Thumbnail
    # Modifies the command ImageMagick's +convert+ options to invert if necessary
    def transformation_command
      trans = super
      trans << " -negate" if darkness > 60
      trans
    end
    
    private
      def darkness
        output = Paperclip.run("identify -verbose -colorspace gray #{File.expand_path(@file.path)}")
        darkness = (1 - output[/ mean: ([.0-9]+)/,1].to_f) * 100
      end
  end
end
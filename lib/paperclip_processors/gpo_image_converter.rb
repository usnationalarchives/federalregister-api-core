module Paperclip
  class GpoImageConverter < Thumbnail
    # GPO images appear to come in at least 2 densities - 300 and 660
    def source_file_options
      options = @source_file_options
      options << "-density"
      options << density
      options
    end

    private

    def density
      @density ||= Paperclip.run("identify -format '%x' #{File.expand_path(@file.path)}")
    end
  end
end

module Paperclip
  class PngCrush < Processor
    def make
      src = @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode

      begin
        success = Paperclip.run("pngcrush -rem alla -nofilecheck -reduce -m 7 #{File.expand_path(src.path)} #{File.expand_path(dst.path)}")
      rescue Cocaine::ExitStatusError => e
        raise PaperclipError, "There was an error attempting to run pngcrush for #{@basename}" if @whiny
      rescue Cocaine::CommandNotFoundError => e
        raise Paperclip::CommandNotFoundError.new("Could not run the `pngcrush` command. Please install pngcrush.")
      end

      dst
    end
  end
end

module Diffy
  module Format

    def html_without_unchanged_lines
      Diffy::CustomFormatter.new(self, options.merge(:highlight_words => true)).to_s
    end

  end
end

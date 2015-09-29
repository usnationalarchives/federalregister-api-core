module CustomDiffy
  module Format
    include Diffy::Format

    def html
      CustomDiffy::HtmlFormatter.new(self, options.merge(:highlight_words => true)).to_s
    end

  end
end

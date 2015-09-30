module Diffy
  class CustomFormatter < Diffy::HtmlFormatter
    # NOTE: This Diffy class was customized by ommitting the processing of
    # <li> tag items with a ".unchanged" html class so they would not
    # appear in the generated html diff.

    def wrap_line(line)
      cleaned = clean_line(line)
      case line
      when /^(---|\+\+\+|\\\\)/
        '    <li class="diff-comment"><span>' + line.chomp + '</span></li>'
      when /^\+/
        '    <li class="ins"><ins>' + cleaned + '</ins></li>'
      when /^-/
        '    <li class="del"><del>' + cleaned + '</del></li>'
      when /^@@/
        '    <li class="diff-block-info"><span>' + line.chomp + '</span></li>'
      end
    end

  end
end

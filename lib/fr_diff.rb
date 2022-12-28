class FrDiff
  class CommandLineError < StandardError; end
  attr_reader :file1, :file2

  def initialize(file1, file2, options={})
    @file1 = file1
    @file2 = file2
  end

  EXPECTED_EXIT_CODES = [0,1]
  def diff
    stdout, stderr, status = Open3.capture3(
      "diff #{file1} #{file2}"
    ) 

    if EXPECTED_EXIT_CODES.include? status.exitstatus
      stdout
    else
      Honeybadger.notify(
        :error_class   => "FrDiff failed to generate diff.",
        :error_message => stderr,
        :parameters => {
          :file1 => file1,
          :file2 => file2
        }
      )
      raise FrDiff::CommandLineError
    end
  end

  def html_diff(options={})
    strings_to_ignore = options.fetch(:ignore, nil)

    html_diff = diff_from_diffy

    if strings_to_ignore
      html_diff = html_diff.split("\n").reject do |line|
        strings_to_ignore.any?{|prefix| line =~ /#{prefix}/ }
      end.join("\n") + "\n" #adding a trailing newline here as the join doesn't do so
    end

    html_diff
  end

  private

  def diff_from_diffy
    @diff_from_diffy ||= Diffy::Diff.new(
      file1,
      file2,
      :source => 'files',
      :include_plus_and_minus_in_html => true
    ).to_s(:html_without_unchanged_lines)
  end
end

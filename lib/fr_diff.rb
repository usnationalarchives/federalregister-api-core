class FrDiff
  class CommandLineError < StandardError; end
  attr_reader :file1, :file2

  def initialize(file1, file2, options={})
    @file1 = file1
    @file2 = file2
  end

  def diff
    line = Cocaine::CommandLine.new(
      "diff",
      ":file1 :file2",
      :expected_outcodes => [0, 1]
    )

    begin
      line.run(
        :file1 => file1,
        :file2 => file2
      )
    rescue Cocaine::ExitStatusError => e
      Honeybadger.notify(
        :error_class   => "FrDiff failed to generate diff.",
        :error_message => e.message,
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
      html_diff = html_diff.reject do |line|
        strings_to_ignore.any?{|prefix| line =~ /#{prefix}/ }
      end.to_s
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

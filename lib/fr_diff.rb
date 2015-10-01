class FrDiff
  class CallCommandLineError < StandardError; end
  attr_reader :file1, :file2, :strings_to_reject

  def initialize(file1, file2, options={})
    @strings_to_reject = options[:strings_to_reject]
    @file1 = file1
    @file2 = file2
  end

  def diff
    begin
      Cocaine::CommandLine.new(
        "diff",
        "#{file1} #{file2}",
        :expected_outcodes => [0, 1] #TODO: BC Interpolate commands via Cocaine
      ).run
    rescue
      Honeybadger.notify(
        :error_class   => "FrDiff failed to generate diff.",
        :error_message => e.message,
        :parameters => {
          :reprocessed_issue_id => reprocessed_issue.id,
          :date => date
        }
      )
      raise CallCommandLineError
    end
  end

  def html_diff
    if strings_to_reject
      diff_from_diffy.reject do |line|
        strings_to_reject.any?{|prefix| line =~ /#{prefix}/ }
      end.to_s
    else
      diff_from_diffy
    end
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

class PatchNotApplicable < StandardError
  attr_reader :file_path, :reversed, :output, :other_patch_errors

  def initialize(file_path:, reversed:, output:, other_patch_errors:)
    @file_path = file_path
    @reversed = reversed
    @reversed = "false" if @reversed.blank?
    @output = output
    @other_patch_errors = other_patch_errors

    output_message if Rails.env.development?
  end

  def message
    method_symbols = [:file_path, :reversed, :output, :other_patch_errors]

    message = "\n  Patching issues encountered:\n"
    method_symbols.each do |method_symbol|
      message << "\t#{method_symbol} : #{send(method_symbol)}\n"
    end
    message
  end

  def output_message
    puts Rainbow(message).red
  end
end

module ImagePipeline::ImageDescrunching
  class DescrunchFailure < StandardError; end

  def gpo_scrunched_image?(path)
    line = Terrapin::CommandLine.new("head -c #{possible_offsets[-1]}", ":file_path")
    output = line.run(file_path: path)
    output.include? 'GPO'
  end

  def descrunch!(input_path)
    line = Terrapin::CommandLine.new("dynamite", ":input_path :output_path :offset")
    possible_offsets.each do |offset|
      begin
        Tempfile.create do |tempfile|
          line.run(
            input_path:  input_path,
            output_path: tempfile.path,
            offset:      offset
          )
          # Mutate original file with descrunched version
          IO.copy_stream(tempfile.path, input_path)
        end

        break
      rescue Terrapin::ExitStatusError => e
        if offset == possible_offsets[-1]
          raise DescrunchFailure
        else
          next
        end
      end
    end
  end

  private

  def possible_offsets
    (0..40).to_a
  end

end

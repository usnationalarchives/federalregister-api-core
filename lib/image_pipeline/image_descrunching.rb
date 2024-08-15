module ImagePipeline::ImageDescrunching
  class DescrunchFailure < StandardError; end
  class DescrunchTimeoutFailure < DescrunchFailure; end
  class DescrunchHardTimeoutFailure < DescrunchFailure; end

  def gpo_scrunched_image?(path)
    line = Terrapin::CommandLine.new("head -c #{possible_offsets[-1]}", ":file_path")
    output = line.run(file_path: path)
    output.include? 'GPO'
  end

  EXPECTED_BYTE_OFFSETS = [18, 14]
  def descrunch!(input_path)
    # SIGTERM after 10s, SIGKILL after an additional 5s
    timeout_cmd = "timeout -k 5 10"

    line = Terrapin::CommandLine.new("#{timeout_cmd} bin/pkware-exploder", "--input :input_path --output :output_path --byte-offset :offset")
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
        if EXPECTED_BYTE_OFFSETS.exclude?(offset)
          Honeybadger.notify("Unexpected byte offset of #{offset} used to descrunch #{tempfile.path}")
        end

        break
      rescue Terrapin::ExitStatusError => e
        # SIGTERM from timeout cmd
        raise DescrunchTimeoutFailure if e.message.include?("returned 124")
        # SIGKILL from timeout cmd
        raise DescrunchHardTimeoutFailure if e.message.include?("returned 137")

        raise DescrunchFailure if offset == possible_offsets[-1]

        next
      end
    end
  end

  private

  def possible_offsets
    # We expect 18 to be the primary offset used, though 14 has occasionally been used
    (EXPECTED_BYTE_OFFSETS + (0..40).to_a).uniq
  end

end

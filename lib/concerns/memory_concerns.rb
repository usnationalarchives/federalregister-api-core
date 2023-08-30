# require ProcessConcerns to have been included
module MemoryConcerns
  # When processing large XML files with Nokogiri, the full file is loaded into
  # memory - for large files this will allocate a lot of memory that isn't
  # returned to the OS after the job. We may not process another large file for
  # some time and holding onto this memory is inefficient.
  # This allows us to enforce a threshold after the job is complete.
  def enforce_memory_threshold(args)
    over_threshold = args[:end_mem] > Settings.sidekiq.memory_threshold.to_i

    if over_threshold
      log_stats = {
        pid: pid,
        start_mem: args[:start_mem],
        end_mem: args[:end_mem],
        mem_used: args[:change],
        job: args[:job],
        queue: args[:queue],
        msg: "Over memory threshold, killing process."
      }

      Sidekiq.logger.warn log_stats
      Process.kill("TERM", pid)
    end
  end
end

module Sidekiq
  class SidekiqMemoryLogger
    include ProcessConcerns
    include MemoryConcerns

    def call(worker, job, queue)
      start_mem = maxrss
      yield
      end_mem = maxrss

      change = end_mem - start_mem

      RequestStore[:memory_usage] = {
        start_mem: start_mem,
        end_mem: end_mem,
        change: change
      }

      if Settings.sidekiq.memory_threshold
        enforce_memory_threshold({
          change: change,
          end_mem: end_mem,
          job: job,
          queue: queue,
          start_mem: start_mem
        })
      end
    end
  end
end

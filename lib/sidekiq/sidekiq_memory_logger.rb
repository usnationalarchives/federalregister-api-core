module Sidekiq
  class SidekiqMemoryLogger
    include ProcessConcerns

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
    end
  end
end

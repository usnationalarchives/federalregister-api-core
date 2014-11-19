module MemInfo
  # This uses backticks to figure out the pagesize, but only once
  # when loading this module.
  # You might want to move this into some kind of initializer
  # that is loaded when your app starts and not when autoload
  # loads this module.
  KERNEL_PAGE_SIZE = `getconf PAGESIZE`.chomp.to_i rescue 4096 
  STATM_PATH       = "/proc/#{Process.pid}/statm"
  STATM_FOUND      = File.exist?(STATM_PATH)

  def self.rss
    STATM_FOUND ? (File.read(STATM_PATH).split(' ')[1].to_i * KERNEL_PAGE_SIZE) / 1024 : 0
  end
end

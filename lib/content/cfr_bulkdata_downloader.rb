module Content
  class CfrBulkdataDownloader
    require 'fileutils'
    require 'open-uri'

    def self.download(options)
      options.symbolize_keys!

      year = options[:year]
      force_download = options[:force_download] || false

      raise "You must provide a year! Usage: rake content:cfr:download YEAR=2011" if year.nil?

      new(year, force_download).download
    end

    attr_accessor :year, :force_download, :perform_download, :url, :cfr_bulkdata_dir, :bulkfile_path, :cfr_data_dir

    def initialize(year, force_download)
      @year = year
      @force_download = force_download
      @perform_download= true

      @url = "https://www.gpo.gov/fdsys/bulkdata/CFR/#{@year}/CFR-#{@year}.zip"

      @cfr_bulkdata_dir = "#{RAILS_ROOT}/data/cfr/bulkdata"
      @bulkfile_path = "#{@cfr_bulkdata_dir}/#{File.basename(@url)}"

      @cfr_data_dir =  "#{RAILS_ROOT}/data/cfr/#{@year}"

    end
  
    def download
      prep_for_download
     
      if perform_download
        download_zip
        extract
      end
    end

    def prep_for_download
      if File.exists?(bulkfile_path) && !force_download
        puts "Zip file exists. Skipping #{url}..."
        perform_download = false
      elsif File.exists?(bulkfile_path) && force_download
        puts "removing #{bulkfile_path}"
        FileUtils.rm(bulkfile_path)
        puts "removing files from #{cfr_data_dir}"
        FileUtils.rm_rf(cfr_data_dir)
        perform_download = true
      end

      FileUtils.mkdir_p(cfr_bulkdata_dir)
      FileUtils.mkdir_p(cfr_data_dir)
    end

    def download_zip
      FederalRegisterFileRetriever.download(url, bulkfile_path)
    end

    def extract
      puts "extracting #{bulkfile_path}..."
      Zip::ZipFile.open(bulkfile_path).each do |file|
        extract_path = "#{cfr_data_dir}/#{file.name}"
        FileUtils.mkdir_p(File.dirname(extract_path))
        file.extract(extract_path)
      end
    end
  end
end

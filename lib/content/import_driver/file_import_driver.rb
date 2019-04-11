module Content
  class ImportDriver
    class FileImportDriver < Content::ImportDriver
      def run
        load "#{Rails.root}/Rakefile"

        ENV['DATE'] = ">#{(Date.current - 1.day).to_s(:iso)}"
        Rake::Task["content:gpo_images:convert_eps"].invoke
      end

      def lockfile_name
        "eps_file_import_driver.lock"
      end
    end
  end
end

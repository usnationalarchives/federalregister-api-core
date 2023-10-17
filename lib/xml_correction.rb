require "open3"

class XmlCorrection
  extend Memoist

  attr_accessor :errors
  attr_reader :patch_dir

  def initialize(publication_date)
    @errors = {}
    @publication_date = publication_date
  end

  def patch_files
    sequential_patch_file_paths.map do |patch_file_dir|
      PatchFile.new(file_path: patch_file_dir)
    end
  end
  memoize :patch_files


  # Opens each directory's patches and applies them sequentially
  def apply
    patch_files.select{|p| p.applicable?}.each do |patch_file|
      Rails.logger.info("Applying #{patch_file.file_path}...")
      patch_file.try(:apply, document_issue_xml_path)
    end
  end


  def valid?
    validate
    errors.empty?
  end

  def validate
    validate_metadata
    validate_patch_files if errors.empty?
  end

  private

  attr_reader :publication_date

  def sequential_patch_file_paths
    if File.directory?(path_manager.document_issue_xml_corrections_path)
      Dir.
        entries(path_manager.document_issue_xml_corrections_path).
        reject{|x| ['.','..'].include?(x) }.
        sort.
        map{|patch_number_dir| File.join(path_manager.document_issue_xml_corrections_path, patch_number_dir)}.
        map{|dir| Dir.glob("#{dir}/*.patch").first }.
        compact #This may be unnecessary in the real world
    else
      []
    end
  end

  def path_manager
    FileSystemPathManager.new(publication_date)
  end

  def document_issue_xml_path
    path_manager.document_issue_xml_path
  end

  def validate_metadata
    if metadata
      if metadata.patches&.present?
        unless metadata.patches.all? { |name, details| name.is_a?(String) }
          errors[:metadata] = "patches must be strings and in the form `001`, `002`, etc."
        end
      else
        errors[:metadata] = "must contain at least one patch"
      end
    else
      errors[:metadata] = "invalid meta.yml"
    end
  end

  def validate_patch_files
    if patch_files.any? { |p| !p.valid? }
      errors[:patch_files] = "all patch files must be valid"
    else
      patch_errors = []

      errors[:patch_files] = patch_errors if patch_errors.present?
    end
  end

  class PatchFile

    attr_reader :file_path

    def initialize(file_path:)
      @file_path = file_path
    end

    def applicable?
      true
    end

    def valid?
      true
    end

    def apply(path)
      command = "patch #{path} -i #{file_path} --no-backup-if-mismatch"

      output, status = Open3.capture2(command)

      if status.exitstatus != 0
        rejection_path = nil
        other_patch_errors = nil

        # ex: "1 out of 2 hunks FAILED -- saving rejects to file /tmp/title_version_3920170903-16364-1ni20eh.xml.rej"
        rejection_output = output.strip.match(/([-\w '\/.\n]+\.rej)/)

        if rejection_output
          rejection_path = rejection_output[1]
        else
          other_patch_errors = output
        end

        reversed = output.include?("Reversed (or previously applied)")

        raise PatchNotApplicable.new(
          file_path: file_path.gsub(Rails.root.to_s, ""),
          reversed: reversed ? "true" : "false",
          output: output,
          other_patch_errors: other_patch_errors.present? ? other_patch_errors : nil,
        )
      end

    ensure
      # remove .reject xml files
      if rejection_path && File.exist?(rejection_path) && !Rails.env.development?
        File.delete(rejection_path)
      end
    end

    private


    def patch_errors(rejection_path)
      return nil unless rejection_path

      File.read(rejection_path)
    rescue Errno::ENOENT
      nil
    end

  end

end

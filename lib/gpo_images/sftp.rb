class GpoImages::Sftp
  delegate :remove, :close, :download!, :to => :connection

  def filenames_with_sizes
    filenames_with_sizes = []
    connection.dir.foreach("/") do |entry|
      if entry.attributes.size > 0
        filenames_with_sizes.push([entry.name, entry.attributes.size])
      end
    end
    filenames_with_sizes
  end

  def remove_files_from_sftp_server(filenames)
    # NOTE: Net::SFTP.start is called instead of the private method 'connection'
    # in order to use a new, non-memoized connection that accepts a block.
    Net::SFTP.start(
      'ftp.gpo.gov',
      SECRETS["gpo_sftp"]["username"],
      :password => SECRETS["gpo_sftp"]["password"],
      :auth_methods => ["password"]
    ) do |sftp|
      filenames.each do |filename|
        Rails.logger.info("Deleting #{filename} from GPO SFTP...")
        sftp.remove(filename)
      end
    end
  end

  private

  def connection
    @connection ||= Net::SFTP.start(
      'ftp.gpo.gov',
      SECRETS["gpo_sftp"]["username"],
      :password => SECRETS["gpo_sftp"]["password"],
      :auth_methods => ["password"]
    )
  end
end

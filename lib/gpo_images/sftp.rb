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
    filenames.each do |filename|
      Rails.logger.info("Deleting #{filename} from GPO SFTP...")
      connection.remove!(filename)
    end
  end

  private

  def connection
    if @connection && @connection.open?
      @connection
    else
      @connection = start_connection
    end
  end

  def start_connection
    Net::SFTP.start(
      'ftp.gpo.gov',
      SECRETS["gpo_sftp"]["username"],
      :password => SECRETS["gpo_sftp"]["password"],
      :auth_methods => ["password"]
    )
  end

end

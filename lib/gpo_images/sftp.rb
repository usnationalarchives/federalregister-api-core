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

  private

  def connection
    @connection ||= Net::SFTP.start('ftp.gpo.gov', SECRETS["gpo_sftp"]["username"], :password => SECRETS["gpo_sftp"]["password"])
  end
end

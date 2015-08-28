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

  def secrets
    secrets ||= YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
  end

  def connection
    @connection ||= Net::SFTP.start('ftp.gpo.gov', secrets["gpo"]["username"], :password => secrets["gpo"]["password"])
  end
end

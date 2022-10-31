class GpoImages::Sftp
  delegate :remove, :close, :download!, :rmdir!, :to => :connection

  def initialize(username: Rails.application.secrets[:gpo_sftp][:username], password: Rails.application.secrets[:gpo_sftp][:password])
    @username = username
    @password = password
  end

  def list_directories(dir)
    directories = []
    connection.dir.foreach('/') do |sftp_object|
      if sftp_object.directory? && ['..','.'].exclude?(sftp_object.name)
        directories << sftp_object.name
      end
    end
    directories
  end

  def filenames_with_sizes(dir="/", recursive_directory_search=false, exclude_empty_files=true)
    sftp_directories     = [dir]
    filenames_with_sizes = []
    while sftp_directories.size > 0
      sftp_directory = sftp_directories.pop
      connection.dir.foreach(sftp_directory) do |sftp_object|
        if sftp_object.file? && !sftp_object.name.start_with?('.nfs') && (exclude_empty_files ? (sftp_object.attributes.size > 0) : true)
          if sftp_directory == '/'
            path = ''
          else
            path = "#{sftp_directory}/"
          end
          filenames_with_sizes << ["#{path}#{sftp_object.name}", sftp_object.attributes.size]
        elsif recursive_directory_search && sftp_object.directory? && ['..','.'].exclude?(sftp_object.name)
          if sftp_directory == '/'
            path = '/'
          else
            path = "#{sftp_directory}/"
          end
          sftp_directories << "#{path}#{sftp_object.name}"
        end
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

  def refresh_connection!
    @connection = start_connection
  end

  private

  attr_reader :username, :password

  def connection
    if @connection && @connection.open?
      @connection
    else
      refresh_connection!
    end
  end

  def start_connection
    Net::SFTP.start(
      Settings.cron.images.sftp_hostname,
      username,
      :password => password,
      :auth_methods => ["password"],
      :timeout => 30
    )
  end

end

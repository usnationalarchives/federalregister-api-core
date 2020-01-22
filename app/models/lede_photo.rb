class LedePhoto < ApplicationModel
  attr_reader :flickr_photo_id
  has_many :entries
  has_attached_file :photo,
                    :styles => {
                      :navigation => ["393", :jpg],
                      :homepage => ["450", :jpg],
                      :large => ["800", :jpg],
                      :full_size => ["", :jpg]
                    },
                    :processors => [:thumbnail],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.secrets[:aws][:access_key_id],
                      :secret_access_key => Rails.application.secrets[:aws][:secret_access_key],
                      :s3_region => 'us-east-1'
                    },
                    :s3_protocol => 'https',
                    :bucket => 'lede-photos.federalregister.gov',
                    :path => ":id/:style.:extension"

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  before_save :download_and_crop_file

  def download_and_crop_file
    if url.present?
      file_path = Tempfile.new('flickr.jpg').path
      Rails.logger.warn "FILE NAME => #{file_path}"
      FederalRegisterFileRetriever.download(url, file_path)

      if crop_x
        dst = Tempfile.new('flickr.jpg')
        dst.binmode

        command = <<-end_command
          "#{ File.expand_path(file_path) }[0]"
          -crop "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
          "#{ File.expand_path(dst.path) }"
        end_command
        Rails.logger.warn(command)
        Paperclip.run("convert", command.gsub(/\s+/, " "))
        file_path = dst.path
      end

      file = File.open(file_path)
      self.photo = file
      file.close
    end
  end

  def flickr_photo_id=(photo_id)
    @flickr_photo_id = photo_id
  end
end

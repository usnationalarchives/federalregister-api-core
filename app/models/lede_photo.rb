class LedePhoto < ApplicationModel
  has_many :entries
  has_attached_file :photo,
                    :styles => { :small => ["150", :jpg], :medium => ["245", :jpg], :large => ["580", :jpg], :full_size => ["", :jpg] },
                    :processors => [:thumbnail]
  
  before_save :download_and_crop_file
  
  private
  
  def download_and_crop_file
    if url.present?
      file_path = Tempfile.new('flickr.jpg').path
      Rails.logger.warn "FILE NAME => #{file_path}"
      Curl::Easy.download(url, file_path)
      
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
      
      self.photo = File.open(file_path)
    end
  end
end
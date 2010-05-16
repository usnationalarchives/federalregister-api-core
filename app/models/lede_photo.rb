=begin Schema Information

 Table name: lede_photos

  id                 :integer(4)      not null, primary key
  credit             :string(255)
  credit_url         :string(255)
  photo_file_name    :string(255)
  photo_content_type :string(255)
  photo_file_size    :integer(4)
  photo_updated_at   :datetime
  url                :string(255)
  crop_width         :integer(4)
  crop_height        :integer(4)
  crop_x             :integer(4)
  crop_y             :integer(4)

=end Schema Information

class LedePhoto < ApplicationModel
  attr_reader :flickr_owner_id
  has_many :entries
  has_attached_file :photo,
                    :styles => { :small => ["140", :jpg], :medium => ["245", :jpg], :large => ["580", :jpg], :full_size => ["", :jpg] },
                    :processors => [:thumbnail]
  
  before_save :download_and_crop_file
  before_save :get_credit_info_from_flickr
  
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
  
  def flickr_owner_id=(owner_id)
    @flickr_owner_id = owner_id
  end
  
  private
  
    def get_credit_info_from_flickr
      if @flickr_owner_id.present?
        person = Flickr::Person.new(@flickr_owner_id)
        self.credit = person.real_name.present? ? person.real_name : person.user_name
        self.credit_url = person.profile_url
      end
    
      true
    end
end

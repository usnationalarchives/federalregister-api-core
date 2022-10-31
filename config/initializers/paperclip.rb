Paperclip.interpolates :identifier do |attachment, style|
  attachment.instance.identifier
end

Paperclip.interpolates :token do |attachment, style|
  attachment.instance.token
end

Paperclip.interpolates :creation_year do |attachment, style|
  attachment.instance.created_at.year
end

Paperclip.interpolates :creation_month do |attachment, style|
  attachment.instance.created_at.strftime("%m")
end

Paperclip.interpolates :document_number do |attachment, style|
  attachment.instance.document_number
end

Paperclip.interpolates :style_if_not_with_banner do |attachment, style|
  case style
  when :with_banner
    ''
  else
    "#{style}/"
  end
end

Paperclip.options[:command_path] = "/usr/local/bin/"

if Settings.paperclip.abort_on_s3_error
  module Paperclip
    module Storage
      module S3

        def copy_to_local_file(style, local_dest_path)
          log("copying #{path(style)} to local file #{local_dest_path}")
          ::File.open(local_dest_path, 'wb') do |local_file|
            s3_object(style).get do |chunk|
              local_file.write(chunk)
            end
          end
        rescue Aws::Errors::ServiceError => e
          raise "Aborting Paperclip processing due to S3 error (This is a custom CJ error). #{e.inspect}"
          warn("#{e} - cannot copy #{path(style)} to local file #{local_dest_path}")
          false
        end

      end
    end
  end
end

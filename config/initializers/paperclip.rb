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

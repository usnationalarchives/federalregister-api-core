Paperclip.interpolates :identifier do |attachment, style|
  attachment.instance.identifier
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


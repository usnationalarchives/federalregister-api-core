Paperclip.interpolates :identifier do |attachment, style|
  attachment.instance.identifier
end

Paperclip.interpolates :document_number do |attachment, style|
  attachment.instance.document_number
end

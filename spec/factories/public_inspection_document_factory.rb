Factory.define :public_inspection_document do |doc|
  doc.publication_date Date.current
  doc.sequence(:document_number) {|n| "abc-#{sprintf("%0000d",n)}" }
end

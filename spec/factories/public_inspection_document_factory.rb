Factory.define :public_inspection_document do |doc|
  doc.subject_1 "Test Subject 1" #Needed so slug is not an empty string
  doc.publication_date Date.current
  doc.sequence(:document_number) {|n| "abc-#{sprintf("%0000d",n)}" }
end

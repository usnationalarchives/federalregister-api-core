Factory.define :entry do |e|
  e.granule_class "NOTICE"
  e.sequence(:document_number) {|n| "abc-#{sprintf("%0000d",n)}" }
  e.publication_date Date.current
end
Factory.define :entry do |e|
  e.sequence(:document_number) {|n| "abc-#{sprintf("%0000d",n)}" }
end
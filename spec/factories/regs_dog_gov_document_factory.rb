Factory.define :regs_dot_gov_document do |e|
  e.sequence(:regulations_dot_gov_document_id) {|n| "HHS_FRDOC_0001-#{sprintf("%0000d",n)}"}
  e.sequence(:regulations_dot_gov_object_id) {|n| n}
  e.sequence(:federal_register_document_number) {|n| "abc-#{sprintf("%0000d",n)}" }
end

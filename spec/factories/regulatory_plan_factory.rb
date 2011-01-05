Factory.define :regulatory_plan do |e|
  e.sequence(:regulation_id_number) {|n| "ABCD-#{sprintf("%0000d",n)}" }
end
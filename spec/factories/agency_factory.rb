Factory.define :agency do |a|
  a.sequence(:name) {|n| "Agency #{n}" }
end
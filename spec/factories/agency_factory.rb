Factory.define :agency do |f|
  f.sequence(:name) {|n| "Agency #{n}" }
  f.active true
end
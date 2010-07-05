Factory.define :agency do |f|
  f.sequence(:name) {|n| "Agency #{n}" }
end
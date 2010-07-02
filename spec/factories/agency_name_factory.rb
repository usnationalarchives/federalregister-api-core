Factory.define :agency_name do |f|
  f.sequence(:name) {|n| "Agency Name #{n}" }
end
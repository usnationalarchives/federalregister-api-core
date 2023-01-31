Factory.define :regs_dot_gov_docket do |d|
  d.sequence(:id) {|n| "HHS_FRDOC_000#{n}"}
  d.agency_id "TREAS"
end

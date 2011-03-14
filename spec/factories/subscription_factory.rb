Factory.define :subscription do |f|
  f.email  'user@example.com'
  f.requesting_ip '127.0.0.1'
  f.search_conditions( {:term => "BAI"} )
  f.environment Rails.env
end
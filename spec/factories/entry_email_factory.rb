Factory.define :entry_email do |f|
  f.association :entry
  f.remote_ip '127.0.0.1'
  f.sender 'john.doe@example.com'
  f.recipients 'jane@example.com,judy@example.com'
end
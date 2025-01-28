Factory.define :topic do |e|
  # humanize the number so that slugs are unique
  # the slug creation in the class removes numbers
  e.sequence(:name) {|n| "Topic #{n.humanize}" }
end

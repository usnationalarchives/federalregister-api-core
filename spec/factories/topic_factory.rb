Factory.define :topic do |e|
  e.sequence(:name) {|n| "Topic #{n}" }
end
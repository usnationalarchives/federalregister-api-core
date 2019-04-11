Factory.define :topic_name do |f|
  f.sequence(:name) {|n| "Topic Name #{n}" }
end

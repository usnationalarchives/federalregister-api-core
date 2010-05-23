Factory.define :section do |s|
  s.sequence(:title) {|n| "Section #{n}" }
  s.sequence(:slug) {|n| "section-#{n}" }
end
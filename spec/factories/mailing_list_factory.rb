Factory.define :mailing_list do |f|
  f.title "Articles matching 'Foo'"
  f.search EntrySearch.new(:conditions => {:term => 'Foo'})
end
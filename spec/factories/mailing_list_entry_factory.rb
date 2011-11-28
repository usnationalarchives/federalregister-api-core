Factory.define :mailing_list_entry, :class => MailingList::Entry do |f|
  f.title "Articles matching 'Foo'"
  f.search EntrySearch.new(:conditions => {:term => 'Foo'})
end

module Content
  module EntryCompiler
    def self.perform(date)
      document_numbers = Entry.published_on(date).map(&:document_number)
      Content.run_myfr2_command "bundle exec rake documents:html:compile:all[\"#{document_numbers.join(';')}\"] DATE='#{date}'"
    end
  end
end

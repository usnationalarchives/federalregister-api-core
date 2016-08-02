module Content
  module EntryCompiler
    @queue = :reimport

    def self.perform(date)
      document_numbers = Entry.published_on(date).map(&:document_number)
      date = date.is_a?(String) ? Date.parse(date) : date

      if date >= Date.parse('2000-01-18')
        Content.run_myfr2_command "bundle exec rake documents:html:compile:all[\"#{document_numbers.join(';')}\"] DATE=#{date.to_s(:iso)}"
      end
    end
  end
end

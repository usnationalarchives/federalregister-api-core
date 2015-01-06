module Content
  module EntryCompiler
    def self.perform(type, date)
      Entry.published_on(date).each do |entry|
        Entry.connection.execute("SELECT NOW()") # keep MySQL connection alive; TODO: FIXME
        path = "#{RAILS_ROOT}/data/entries/html/#{type}/#{entry.document_file_path}.html"
        FileUtils.makedirs(File.dirname(path))

        val = Content.render_erb("entries/_#{type}", {:entry => entry})
        File.open(path, 'w') {|f| f.write(val) }
        puts path
      end
    end
  end
end

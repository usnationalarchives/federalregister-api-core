class ApplicationSearch::FileExcerpter < ThinkingSphinx::Excerpter
  def raw_text
    begin
      @raw_text ||= @search.send(:client).excerpts(
        :docs   => [@instance.raw_text_file_path],
        :load_files => true,
        :words  => @search.args.join(' '),
        :query_mode => :extended,
        :index  => "#{Entry.source_of_sphinx_index.sphinx_name}_core"
      ).first
    rescue Riddle::ResponseError
      nil
    end
  end
end

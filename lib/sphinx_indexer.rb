module SphinxIndexer
  class SphinxIndexerError < StandardError; end

  def self.perform(*index_names)
    rotate_indices(index_names)

    delta_indices = index_names.select{|i| i.include?('delta')}
    purge_from_core_index(delta_indices) if delta_indices.present?
  end

  def self.rotate_indices(index_names)
    begin
      line = Cocaine::CommandLine.new(
        "/usr/local/bin/indexer",
        "-c :sphinx_conf :index_names --rotate",
        :environment => {'DATE' => "#{date.to_s(:iso)}"}
      )
      line.run(
        index_names: index_names.join(' '),
        sphinx_conf: ThinkingSphinx::Configuration.instance.config_file
      )
    rescue Cocaine::ExitStatusError => error
      raise SphinxIndexer::SphinxIndexerError
    end
  end

  def self.purge_from_core_index(*delta_indices)
    delta_indices.each do |model|
      model.find_each(select: "id, delta", conditions: {delta: true}) do |record|
        model.core_index_names.each do |index_name|
          model.delete_in_index(index_name, record.sphinx_document_id)
        end
      end
    end
  end
end

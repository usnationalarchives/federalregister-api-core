module SphinxIndexer
  class SphinxIndexerError < StandardError; end

  def self.perform(*index_names)
    rotate_indices(index_names)
  end

  def self.rebuild_delta_and_purge_core(*models)
    delta_index_names = models.map{|model| model.delta_index_names}.flatten.join(' ')
    rotate_indices(delta_index_names)
    purge_from_core_index(models)
  end

  def self.rotate_all
    self.rotate_indices(["--all"])
  end

  def self.rotate_indices(index_names)
    begin
      Cocaine::CommandLine.new(
        "/usr/local/bin/indexer",
        "-c :sphinx_conf :index_names --rotate --nohup"
      ).run(
        index_names: index_names.join(' '),
        sphinx_conf: ThinkingSphinx::Configuration.instance.config_file
      )

      Cocaine::CommandLine.new(
        "/usr/bin/touch",
        ThinkingSphinx::Configuration.instance.pid_file
      ).run
    rescue Cocaine::ExitStatusError => error
      raise SphinxIndexer::SphinxIndexerError
    end
  end

  def self.purge_from_core_index(*models)
    models.each do |model|
      model.find_each(select: "id, delta", conditions: {delta: true}) do |record|
        model.core_index_names.each do |index_name|
          model.delete_in_index(index_name, record.sphinx_document_id)
        end
      end
    end
  end
end

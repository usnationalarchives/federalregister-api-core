module ElasticsearchSpecHelperMethods

  def recreate_actual_pi_index_and_assign_alias!
    PublicInspectionDocumentRepository.new(
      index_name: PublicInspectionDocumentRepository::ACTUAL_INDEX_NAME,
      client: DEFAULT_ES_CLIENT
    ).create_index!(force: true)
    ElasticsearchIndexer.assign_pi_index_alias
  end

end

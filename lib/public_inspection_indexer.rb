class PublicInspectionIndexer

  def self.reindex!
    new.reindex!
  end

  RETRY_LIMIT = 3
  def reindex!
    # Define repositories so we can specify custom index names
    default_repository = PublicInspectionDocumentRepository.new(
      index_name: PublicInspectionDocumentRepository::ACTUAL_INDEX_NAME,
      client: DEFAULT_ES_CLIENT)
    temporary_repository = PublicInspectionDocumentRepository.new(
      index_name: ['fr-public-inspection-documents-temporary', Rails.env].join('-'),
      client: DEFAULT_ES_CLIENT
    )

    # Reindex the alternate index
    temporary_repository.create_index!
    PublicInspectionDocument.bulk_index(
      PublicInspectionDocument.indexable.pre_joined_for_es_indexing,
      refresh: true,
      repository: temporary_repository
    )

    # Assign the index alias to the temporary index
    assign_index_to_alias(default_repository.index_name, temporary_repository.index_name)

    # Reindex the default index
    remaining_retries = RETRY_LIMIT
    begin
      default_repository.delete_index!
    rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e #eg if AWS is taking a snapshot of the index, this request will fail
      if remaining_retries > 0
        puts "Elasticsearch index deletion failure.  Retrying..."
        remaining_retries -= 1
        sleep 5
        retry
      else
        raise e
      end
    end
    
    default_repository.create_index!
    PublicInspectionDocument.bulk_index(
      PublicInspectionDocument.indexable.pre_joined_for_es_indexing,
      refresh: false,
      repository: default_repository
    )

    # Assign the index alias back to the default index
    assign_index_to_alias(temporary_repository.index_name, default_repository.index_name)

    # Delete the temporary index
    temporary_repository.delete_index!
  end

  private

  def assign_index_to_alias(old_index_name, new_index_name)
    DEFAULT_ES_CLIENT.indices.update_aliases body: {
      actions: [
        { remove: { index: old_index_name, alias: $public_inspection_document_repository.index_name } },
        { add: { index: new_index_name, alias: $public_inspection_document_repository.index_name } }
      ]
    }
  end

end

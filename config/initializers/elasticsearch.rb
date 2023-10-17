base_es_settings = {
  host: Rails.application.credentials.dig(:elasticsearch, :host) || Settings.elasticsearch.host,
  transport_options: {
    request: { timeout: 15 }
  },
  retry_on_failure: 1,
  retry_on_status: [429],
  trace: Settings.elasticsearch.trace,
}

DEFAULT_ES_CLIENT = Elasticsearch::Client.new(base_es_settings)
EXTENDED_TIMEOUT_ES_CLIENT = Elasticsearch::Client.new(
  base_es_settings.merge(
    transport_options: {
      request: { timeout: 120 }
    },
  )
)

$public_inspection_document_repository = PublicInspectionDocumentRepository.new(client: DEFAULT_ES_CLIENT)
$entry_repository = EntryRepository.new(client: DEFAULT_ES_CLIENT)
#NOTE: The original reason for defining an additional ES repository was so we could use an extended timeout when indexing.
$extended_timeout_entry_repository = EntryRepository.new(client: EXTENDED_TIMEOUT_ES_CLIENT)

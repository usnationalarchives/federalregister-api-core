DEFAULT_ES_CLIENT = Elasticsearch::Client.new(
  host: Settings.elasticsearch.host,
  transport_options: {
    request: { timeout: 15 }
  },
  retry_on_failure: 1,
  retry_on_status: [429],
  trace: Settings.elasticsearch.trace,
)

$public_inspection_document_repository = PublicInspectionDocumentRepository.new(client: DEFAULT_ES_CLIENT)
$entry_repository = EntryRepository.new(client: DEFAULT_ES_CLIENT)

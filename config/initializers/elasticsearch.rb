DEFAULT_CLIENT = Elasticsearch::Client.new(
  host: SETTINGS['elasticsearch']['host'],
  transport_options: {
    request: { timeout: 10 }
  },
  trace: SETTINGS['elasticsearch']['trace'],
)

$public_inspection_document_repository = PublicInspectionDocumentRepository.new(client: DEFAULT_CLIENT)

DEFAULT_CLIENT = Elasticsearch::Client.new(
  host: 'localhost:9200',#'https://admin:admin@localhost:9200/',#SETTINGS['elasticsearch']['host'],
  # https://admin:admin@elasticsearch:9200
  transport_options: {
    request: { timeout: 10 }
  },
  trace: SETTINGS['elasticsearch']['trace'],
)

$public_inspection_document_repository = PublicInspectionDocumentRepository.new(client: DEFAULT_CLIENT)

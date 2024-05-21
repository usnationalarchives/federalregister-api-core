# This class tells creates an ingest pipeline that tells OpenSearch how and where to store text embeddings
class OpenSearchIngestPipelineRegistrar

  INGEST_PIPELINE_NAME = "nlp-ingest-pipeline"
  def self.create_non_chunked_pipeline(model_id)
    # NOTE: This was the first pass at non-chunked embeddings
    response = Faraday.put("#{base_url}/_ingest/pipeline/#{INGEST_PIPELINE_NAME}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        "description": "A text embedding pipeline",
        "processors": [
          {
            "text_embedding": {
              "model_id": model_id,
              "field_map": {
                "full_text": "full_text_embedding"
              }
            }
          }
        ]
      }.to_json
    end
    puts response.body
  end

  CHUNKING_PIPELINE_NAME = "nlp-chunking-ingest-pipeline"
  TOKEN_LIMIT = 256 # We may want to experiment with this value
  def self.create_chunking_ingest_pipeline!(model_id)
    response = Faraday.put("#{base_url}/_ingest/pipeline/#{CHUNKING_PIPELINE_NAME}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        "description": "A pipeline that chunks and subsequently generates text embeddings",
        "processors": [
          {
            "text_chunking": {
              "algorithm": {
                "fixed_token_length": {
                  "token_limit": TOKEN_LIMIT,
                  "overlap_rate": 0.2,
                  "tokenizer": "standard"
                }
              },
              "field_map": {
                "full_text": "full_text_chunk"
              }
            }
          },
          {
            "text_embedding": {
              "model_id": OpenSearchMlModelRegistrar.model_id,
              "field_map": {
                "full_text_chunk": "full_text_chunk_embedding"
              }
            }
          },
          #NOTE: The removal step appears to be necessary or OpenSearch will assume you're trying to persist the "full_text_chunk" when it's really just an ephemeral part of the processor logic
          {
            "remove": {
              "field": "full_text_chunk"
            }
          }
        ]
      }.to_json
    end
    puts response.body
  end

  HYBRID_SEARCH_NORMALIZATION_PIPELINE_NAME = "hybrid-search-normalization-pipeline"
  def self.create_hybrid_search_normalization_pipeline!
    # NOTE: They hybrid search normalization pipeline is currently being specified at search runtime.  As we move to a more OpenSearch-centric client library, for simplicity's sake, we may want to register this pipeline configuration advance and just reference the pipeline name instead.
    response = Faraday.put("#{base_url}/_search/pipeline/#{HYBRID_SEARCH_NORMALIZATION_PIPELINE_NAME}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = SearchType::HYBRID.temporary_search_pipeline_configuration.to_json
    end
    puts response.body
  end

  def self.base_url
    Settings.elasticsearch.host || Rails.application.credentials.dig(:elasticsearch, :host)
  end

end

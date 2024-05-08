# This class tells creates an ingest pipeline that tells OpenSearch how and where to store text embeddings
class OpenSearchIngestPipelineRegistrar

  INGEST_PIPELINE_NAME = "nlp-ingest-pipeline"
  def self.perform(model_id)
    response = Faraday.put("#{Settings.elasticsearch.host}/_ingest/pipeline/#{INGEST_PIPELINE_NAME}") do |req|
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
  def self.create_chunking_pipeline!(model_id)
    response = Faraday.put("#{Settings.elasticsearch.host}/_ingest/pipeline/#{CHUNKING_PIPELINE_NAME}") do |req|
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
          #NOTE: The removal step appears to be necessary or the 
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

  NORMALIZATION_PIPELINE_NAME = "normalization-pipeline"
  def self.create_normalization_pipeline!
    response = Faraday.put("#{Settings.elasticsearch.host}/_search/pipeline/#{NORMALIZATION_PIPELINE_NAME}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = SearchType::HYBRID.temporary_search_pipeline_configuration.to_json
    end
    puts response.body
  end

end

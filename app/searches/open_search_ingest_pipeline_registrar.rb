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

end

class MlIndexer

  def self.index_corpus
    directory_path = 'data/efs/documents/full_text/raw/2022/11/17'
    files = Dir.entries(directory_path).select { |file| File.file?(File.join(directory_path, file)) }

    files.each_with_index do |file_name, i|
      # Construct the full path of the file
      file_path = File.join(directory_path, file_name)
  
      # Read the contents of the file
      File.open(file_path, "r") do |file|
        puts "Contents of #{file_name}:"
        # puts file.read
        url = "http://elasticsearch.brandon-fr.svc.cluster.local:9200/my-nlp-index/_doc/#{i}"
        response = Faraday.put(url) do |req|
          # Set headers if needed
          req.headers['Content-Type'] = 'application/json'
        
          # Convert payload to JSON and set as request body
          req.body = {
            passage_text: ("#{file_name} " + file.read),
            id: (i + 10)
          }.to_json
        end
      end
    end 
  end

  def self.search(term)
    raise "Provide a search term" unless term.present?
  
    # host = Rails.application.credentials.dig(:elasticsearch, :host) || Settings.elasticsearch.host
    url = "http://elasticsearch.brandon-fr.svc.cluster.local:9200/my-nlp-index/_search"
    response = Faraday.get(url) do |req|
      req.headers['Content-Type'] = 'application/json' # Set the content type if necessary
      payload = {
        "_source": {
          "excludes": [
            "passage_embedding"
          ]
        },
        "query": {
          "bool": {
            "should": [
              {
                "script_score": {
                  "query": {
                    "neural": {
                      "passage_embedding": {
                        "query_text": term,
                        "model_id": "oM0_z44BvKwC543PSZ1Z",
                        "k": 3
                      }
                    }
                  },
                  "script": {
                    "source": "_score * 1.5"
                  }
                }
              }
            ]
          }
        }
      }
      req.body = payload.to_json 
    end

    puts JSON.parse(response.body)
  end

end

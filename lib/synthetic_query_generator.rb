require 'uri'
require 'net/http'
require 'json'
require 'pry'

# This class can be used to generate synthetic queries for use in search relevancy evaluations 
class SyntheticQueryGenerator

  def self.perform(entry_scope)
    api_key = Settings.open_ai_key

    # Directory containing your documents
    documents_dir = '/home/app/data/efs/test_documents'

    # Output file for generated queries and metadata
    output_file = '/home/app/data/efs/output_queries.json'

    # Initialize an empty array to store results
    results = []

    id = 21
    # Process each 
    entry_scope.each do |entry|
      document_text = entry.raw_text

      # Call the API to generate a query
      result = generate_query(document_text, api_key)
      generated_query = result['choices'].first['message']['content'] rescue nil

      # Collect the result
      if generated_query
        entry = {
          id: id,
          llm_generated_query: true,
          notes: nil,
          query_terms: generated_query,
          ratings: [
            {document_number: entry.document_number, rating: 4}
          ]
        }
        results.push(entry)
        id += 1
      end
    end

    # Write results to a JSON file
    File.write(output_file, JSON.pretty_generate(results))

    puts "Query generation complete. Output saved to #{output_file}."
  end

  # Method to call the OpenAI ChatGPT API
  def self.generate_query(document, api_key)
    # Prompt
    prompt = "Pretend you are a regular user of average intelligence using FederalRegister.gov who is using its search engine for doing regulatory research.  Generate a specific query for this document that can be used to evaluate search relevancy on an automated basis (no more than 2-3 words).  Make sure the query does not end with a period or begin with the word 'query'"


    uri = URI('https://api.openai.com/v1/chat/completions')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'

    data = {
      model: "gpt-3.5-turbo",  # Adjust model as necessary
      messages: [{role: "system", content: prompt},
                {role: "user", content: document}]
    }

    request.body = data.to_json
    response = http.request(request)

    if response.code == '429'
      puts "Quota exceeded, stopping further requests."
      return nil
    end

    JSON.parse(response.body)
  end

end


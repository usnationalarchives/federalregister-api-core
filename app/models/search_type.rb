class SearchType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      id: 1,
      identifier: "lexical",
      name: "Lexical (Standard)",
      supports_explain: true,
    },
    {
      id: 2,
      identifier: "neural",
      name: "Neural ML",
      supports_explain: true,
    },
    {
      id: 3,
      identifier: "manually_weighted",
      name: "Manually Weighted Combination",
      supports_explain: true,
    },
    {
      id: 4,
      name: "Hybrid (Normalized Lexical & Neural)",
      identifier: "hybrid",
      supports_explain: false,
      temporary_search_pipeline_configuration: {
        # The purpose of this pipeline configuration is to collect results from all shards and normalize the relevance scores from a lexical query and neural query (these scores occur on different scales)
        "description": "Post-processor for hybrid search",
        "phase_results_processors": [
          {
            "normalization-processor": {
              "normalization": {
                "technique": "l2"
              },
              "combination": {
                "technique": "arithmetic_mean",
                "parameters": {
                  "weights": [
                    # NOTE: Given the nature of our corpus (where specific regulatory terms are often searched for) and the fact that query analytics suggest most of our queries are not several words long and thus don't benefit as much from neural search, apply a heavy weighting towards BM25
                    0.7, # (BM25 Weighting)
                    0.3, # (Neural Weighting)
                  ]
                }
              }
            }
          }
        ]
      }
    }
  ]

  def query_customization 
    false
  end
end

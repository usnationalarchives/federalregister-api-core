class SearchType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      id: 1,
      identifier: "lexical",
      name: "Lexical (Current)",
      es_scoring_functions: [
        {
          "gauss": {
              "publication_date": {
                  "origin": "now",
                  "scale":  "365d",
                  "offset": "30d",
                  "decay":  "0.5" #0.5 is the default
              }
          },
        }
      ],
      supports_explain: true,
      supports_pagination: true,
    },
    {
      id: 2,
      identifier: "lexical_optimized",
      includes_multi_match_query: true,
      name: "Lexical Optimized",
      es_scoring_functions: [],
      supports_explain: true,
      supports_pagination: true,
    },
    {
      id: 5,
      identifier: "lexical_optimized_with_decay",
      includes_multi_match_query: true,
      name: "Lexical Optimized (with decay)",
      es_scoring_functions: [
        {
          "gauss": {
              "publication_date": {
                  "origin": "now",
                  "scale":  "1095d",
                  "offset": "365d",
                  "decay":  "0.3" #0.5 is the default
              }
          },
        }
      ],
      supports_explain: true,
      supports_pagination: true,
    },
    {
      id: 3,
      name: "Hybrid (Function min score)",
      es_scoring_functions: [],
      identifier: "hybrid",
      includes_multi_match_query: true,
      is_hybrid_search: true,
      k_nearest_neighbors: 10,
      min_function_score_for_neural_query: 1.9,
      min_score: nil, # The min score is handled via a somewhat manual function score threshold.  We'll probably want to use the hybrid KNN min score search
      supports_explain: false,
      supports_pagination: true,
    },
    {
      id: 4,
      name: "Hybrid (KNN min score)",
      es_scoring_functions: [],
      identifier: "hybrid_knn_min_score",
      includes_multi_match_query: true,
      is_hybrid_search: true,
      k_nearest_neighbors: nil,
      min_function_score_for_neural_query: nil, # The minimum score is handled via the min_score knn query parameters
      min_score: 0.90,
      supports_explain: false,
      supports_pagination: false,
    }
  ]

  def search_pipeline_configuration
    return unless is_hybrid_search

    # The purpose of this pipeline configuration is to collect results from all shards and normalize the relevance scores from a lexical query and neural query (these scores occur on different scales)
    {
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
  end
end

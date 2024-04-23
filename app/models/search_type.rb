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
    }
  ]
end

class SearchType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      id: 1,
      identifier: "textual",
    },
    {
      id: 2,
      identifier: "neural_ml",
    }
  ]
end

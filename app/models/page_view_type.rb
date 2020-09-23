class PageViewType < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    {
      id: 1,
      identifier:         'document',
      cache_expiry_urls:  ['/api/v1/documents', '/documents/'],
      current_as_of:      'doc_counts:current_as_of',
      filter_expressions: ["^/(documents/|articles/)"],
      historical_set:     "doc_counts:historical",
      temp_set:            "doc_counts:in_progress",
      today_set:           "doc_counts:today",
      yesterday_set:      "doc_counts:yesterday",
    },
    {
      id: 2,
      identifier:     'public_inspection_document',
      cache_expiry_urls:  ['/api/v1/public-inspection-documents', '/public_inspection_documents/'],
      current_as_of:  'public_inspection_doc_counts:current_as_of',
      filter_expressions: ["^/(public_inspection_documents/)"],
      historical_set: "public_inspection_doc_counts:historical",
      temp_set:        "public_inspection_doc_counts:in_progress",
      today_set:       "public_inspection_doc_counts:today",
      yesterday_set:  "public_inspection_doc_counts:yesterday",
    },
  ]

  enum_accessor :identifier
end

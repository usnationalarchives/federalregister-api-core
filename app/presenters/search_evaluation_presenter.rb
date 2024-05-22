class SearchEvaluationPresenter
  extend Memoist
  
  attr_reader :k_value

  def initialize(k_value:)
    @k_value = k_value || 3
  end

  # Rating Scale
  # 0 – No useful information
  # 1 – Some useful information
  # 2 – Significant useful information
  # 3 – Essential useful information
  # 4 – Critical useful information
  DATA = [
    {
      id: 1,
      notes: "narrow keyword term",
      query_terms: "ampaire",
      ratings: [
        {document_number: '2023-17947', rating: 4},
        {document_number: '2021-19926', rating: 4},
      ]
    },
    {
      id: 2,
      notes: "There is one major document here related to the Implementation of the Uniting for Ukraine Parole Process which should be #1 but is being obscured by gaussian decay.  There are a number of other docs related to other countries like Venezuela, Cuba, etc that make reference to the original ukraine parole process doc",
      query_terms: "ukraine parole",
      ratings: [
        {document_number: '2022-09087', rating: 4},
        {document_number: '2022-22739', rating: 3},
        {document_number: '2023-00252', rating: 3},
      ]
    },
    {
      id: 3,
      query_terms: "notification to patients for change in dental network",
      ratings: [
        {document_number: '97-672', rating: 3},
      ]
      },
      {
      id: 4,
      notes: "An OSHA suggested search is currently offered that does a good job of narrowing the scope of the search",
      query_terms: "Vaccination or Testing OSHA November 5, 2021",
      ratings: [
        {document_number: '2022-01532', rating: 4},
        {document_number: '2021-23643', rating: 4},
        {document_number: '2021-25167', rating: 4},
      ]
    },
    {
      id: 5,
      query_terms: "Proposed Final Judgment National Association of Realtors",
      notes: "Gaussian and the lack of quotes around National Association of Realtors seems to be having a mal-impact here",
      ratings: [
        {document_number: 'E8-17800', rating: 4},
        {document_number: 'E8-25989', rating: 4},
        {document_number: 'E8-13902', rating: 4},
        {document_number: 'E8-10417', rating: 3},
      ]
    },
    {
      id: 6,
      query_terms: "flsa firefighter exemptions",
      notes: "E8-16631 seems to be highly relevant, but nothing related to firefighting is surfaced in the highlights/summary",
      ratings: [
        {document_number: 'E8-16631', rating: 4},
        {document_number: 'E7-18027', rating: 4}
      ]
    },
    {
      id: 7,
      query_terms: "Tyme Maidu Tribe",
      notes: "20 results, many of which are relevant, but very similar.  Another example of title",
      ratings: [
        {document_number: '2018-11820', rating: 4},
      ]
    },
    {
      id: 8,
      query_terms: "uflpa entity list",
      notes: "Several docs are titled 'Notice Regarding the Uyghur Forced Labor Prevention Act Entity List'",
      ratings: [
        {document_number: '2018-11820', rating: 4}, #The original notice
        {document_number: '2024-10544', rating: 3},
        {document_number: '2023-26984', rating: 3},
        {document_number: '2023-21131', rating: 3},
        {document_number: '2023-16361', rating: 3},
        {document_number: '2023-12481', rating: 3},
        {document_number: '2023-12178', rating: 1},
        {document_number: '2024-08735', rating: 1},
      ]
    },
    {
      id: 9,
      query_terms: "mattresses from the Philippines",
      ratings: [
        {document_number: '2024-10567', rating: 4},
        {document_number: '2024-04322', rating: 4},
      ]
    },
    {
      id: 10,
      query_terms: "Unlicensed Use of the 6 GHz Band",
      ratings: [
        {document_number: '2023-28006', rating: 4},
        {document_number: '2023-28620', rating: 4},
        {document_number: '2024-02390', rating: 4},
        {document_number: '2024-04494', rating: 4},
      ],
    },
    {
      id: 11,
      notes: "Example of a query for which there are minimially useful results in our corpus, but some things of tangential relevance",
      query_terms: "Grants for women out of prison",
      ratings: [
        {document_number: '2024-09614', rating: 1},
        {document_number: '2024-09795', rating: 1},
        {document_number: '2024-09797', rating: 1},
        {document_number: '2024-09796', rating: 1},
      ]
    },
    {
      id: 12,
      query_terms: "Medicare Program; Changes to the Medicare Advantage and the Medicare Prescription Drug Benefit Program",
      notes: "Example where the user is looking for a single document where this exact phrase is used despite having not quoted it",
      ratings: [
        {document_number: '2024-07105', rating: 4},
      ]
    },
    {
      id: 13,
      query_terms: "us federal government unclaimed funds",
      notes: "Example where the user is looking for a single document where this exact phrase is used despite having not quoted it",
      ratings: [
        {document_number: '2015-32488', rating: 1},
      ]
    },
    {
      id: 14,
      query_terms: "Prohibition on Contracting for Certain Telecommunications and Video Surveillance Services or Equipment",
      ratings: [
        {document_number: '2023-19148', rating: 4},
        {document_number: '2024-02040', rating: 1},
        {document_number: '2020-21033', rating: 1},
      ]
    },
    {
      id: 15,
      query_terms: "2cfr part 200",
      ratings: [
        {document_number: '2023-14600', rating: 4},
      ]
    },
    {
      id: 16,
      query_terms: 'Non-Compete Clause Rule',
      ratings: [
        {document_number: '2024-09171', rating: 4},
        {document_number: '2023-07036', rating: 4},
        {document_number: '2023-00414', rating: 4},
      ]
    },
    {
      id: 17,
      query_terms: '45 C.F.R. § 92.1',
      notes: "This is an example of a search where periods were errantly used between CFR and this appeared to prevent the appearance of the relevant document",
      ratings: [
        {document_number: '2024-02871', rating: 4},
      ]
    },
    {
      id: 18,
      query_terms: 'CMS-2439-F',
      notes: "Example of a case where only one result is available",
      ratings: [
        {document_number: '2024-08085', rating: 4},
      ]
    },
    {
      id: 19,
      query_terms: 'May 10, 2024 and CMS and minimum nursing standards',
      ratings: [
        {document_number: '2024-08273', rating: 4},
      ]
    }

  ]

  def search_types
    [
      SearchType::LEXICAL,
      SearchType::HYBRID,
    ]
  end

  def search_type_rank_eval_responses
    search_types.map{|search_type| rank_eval_request(search_type)}
  end
  memoize :search_type_rank_eval_responses

  ROUNDING_DIGITS = 2
  def search_rankings
    rankings = DATA.map.each do |attr|
      [
        attr.fetch(:query_terms), 
        attr[:notes], 
      ].tap do |row|
        search_types.each_with_index do |search_type, search_type_i|
          row << search_type_rank_eval_responses[search_type_i].
            fetch("details").
            fetch("query_#{attr.fetch(:id)}").
            fetch("metric_score").
            round(ROUNDING_DIGITS)
        end
      end
    end
    total_row = ["TOTAL SCORE", nil]
    search_types.each_with_index do |search_type, i|
      total_row << rankings.sum{|x| x[2+i].round(ROUNDING_DIGITS) }
    end
    rankings << total_row

  end

  private

  def rank_eval_request(search_type)
    response = Faraday.get("#{es_host}/#{index_name}/_rank_eval") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        "metric": {"precision": {k: k_value}},
        "requests": (DATA.map.with_index do |attr, i|
          es_query = EsEntrySearch.new(
            conditions: {term: attr.fetch(:query_terms), search_type_ids: [search_type.id]},
          ).send(search_type.is_hybrid_search ? :hybrid_search_options : :search_options).fetch(:query)
          query_customization = search_type.query_customization
          if query_customization
            es_query[:function_score][:functions] = []
          end

          ratings = attr.fetch(:ratings).map do |rating_attrs|
            { 
              "_index": index_name,
              "_id": Entry.find_by_document_number!(rating_attrs.fetch(:document_number)).id.to_s,
              # "_id": (1..1000).to_a.sample.to_s,
              "rating": rating_attrs.fetch(:rating)
            }
          end

          {
            "id": "query_#{attr.fetch(:id)}",                        
            "request": {                                              
                "query": es_query
            },
            "ratings": ratings
          }
        end),
      }.to_json
    end

    if response.success?
      JSON.parse(response.body)
    else
      raise JSON.parse(response.body).inspect
    end
  end
  memoize :rank_eval_request

  def es_host
    Rails.application.credentials.dig(:elasticsearch, :host) || Settings.elasticsearch.host
  end

  def index_name
    $entry_repository.index_name
  end
  memoize :index_name

end

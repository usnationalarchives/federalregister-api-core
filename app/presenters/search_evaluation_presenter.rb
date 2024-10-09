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
    },
    {
      id: 20,
      query_terms: 'Native American Early childhood Education infrastructure Funding',
      ratings: [
        {document_number: '2024-05573', rating: 4},
        {document_number: '2024-03631', rating: 3},
      ]
    },
    {
      id: 48,
      query_terms: 'CLC Holdings Limited',
      notes: "Good example of a query that uses common generic terms, but should be interpreted as a phrase",
      ratings: [
        {document_number: '2020-28101', rating: 4},
        {document_number: '2019-17409', rating: 4},
        {document_number: '2018-18766', rating: 4},
      ]
    },
    {
      "id": 22,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Find information on Historically Black Colleges advisory meeting.",
      "ratings": [
        {
          "document_number": "2015-10596",
          "rating": 4
        }
      ]
    },
    {
      "id": 23,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Feedback on FRA Safety Advisory Extension.",
      "ratings": [
        {
          "document_number": "2015-12580",
          "rating": 4
        }
      ]
    },
    {
      "id": 24,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "\"Steel wire garment hangers PRC antidumping review\"",
      "ratings": [
        {
          "document_number": "2015-28757",
          "rating": 4
        }
      ]
    },
    {
      "id": 25,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "DEA summary disposition for lack of state authority.",
      "ratings": [
        {
          "document_number": "2016-08572",
          "rating": 4
        }
      ]
    },
    {
      "id": 26,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Customs duties interest rates for July 2016.",
      "ratings": [
        {
          "document_number": "2016-19167",
          "rating": 4
        }
      ]
    },
    {
      "id": 27,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "North Carolina Ward Transformer Superfund Site Consent",
      "ratings": [
        {
          "document_number": "2016-23386",
          "rating": 4
        }
      ]
    },
    {
      "id": 28,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Cancelation of United States Investment Advisory Council meeting.",
      "ratings": [
        {
          "document_number": "2017-02393",
          "rating": 4
        }
      ]
    },
    {
      "id": 29,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Amendments to Coast Guard organizational changes.",
      "ratings": [
        {
          "document_number": "2017-12578",
          "rating": 4
        }
      ]
    },
    {
      "id": 30,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "\"United Rolls Inc. Consent Decree public comment\"",
      "ratings": [
        {
          "document_number": "2017-23915",
          "rating": 4
        }
      ]
    },
    {
      "id": 31,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "\"Class E airspace Spanish Fork UT rule\"",
      "ratings": [
        {
          "document_number": "2018-02325",
          "rating": 4
        }
      ]
    },
    {
      "id": 32,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "MSHA Petition Modification Prairie Eagle Mine.",
      "ratings": [
        {
          "document_number": "2018-24913",
          "rating": 4
        }
      ]
    },
    {
      "id": 33,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Coast Guard Information Collection Request Comments.",
      "ratings": [
        {
          "document_number": "2018-25481",
          "rating": 4
        }
      ]
    },
    {
      "id": 34,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "FDA approved information collections list 2019.",
      "ratings": [
        {
          "document_number": "2019-01812",
          "rating": 4
        }
      ]
    },
    {
      "id": 35,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Submit comments for Atlantic Mackerel, Squid, Amendment.",
      "ratings": [
        {
          "document_number": "2019-02697",
          "rating": 4
        }
      ]
    },
    {
      "id": 36,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Airbus SAS Main Landing Gear Inspection AD",
      "ratings": [
        {
          "document_number": "2019-02938",
          "rating": 4
        }
      ]
    },
    {
      "id": 37,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Query: Antidumping and countervailing duty orders initiation summary.",
      "ratings": [
        {
          "document_number": "2019-14951",
          "rating": 4
        }
      ]
    },
    {
      "id": 38,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Exclusive Patent License for Targeted CAR Therapies.",
      "ratings": [
        {
          "document_number": "2019-17866",
          "rating": 4
        }
      ]
    },
    {
      "id": 39,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Loan Rehabilitation Payment Collection - Extension Request",
      "ratings": [
        {
          "document_number": "2020-06899",
          "rating": 4
        }
      ]
    },
    {
      "id": 40,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Emergency Beacon Registrations for NOAA.",
      "ratings": [
        {
          "document_number": "2020-27112",
          "rating": 4
        }
      ]
    },
    {
      "id": 41,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Petition for Banggai cardinalfish conservation comment.",
      "ratings": [
        {
          "document_number": "2021-16220",
          "rating": 4
        }
      ]
    },
    {
      "id": 42,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "CDC Lead Exposure Prevention Advisory Committee nominations",
      "ratings": [
        {
          "document_number": "2021-19222",
          "rating": 4
        }
      ]
    },
    {
      "id": 43,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Establish RNAV route T-374 in Alaska.",
      "ratings": [
        {
          "document_number": "2021-24631",
          "rating": 4
        }
      ]
    },
    {
      "id": 44,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "NIH grant applications meeting closed March 2022.",
      "ratings": [
        {
          "document_number": "2022-00257",
          "rating": 4
        }
      ]
    },
    {
      "id": 45,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Electronic Funds Transfer Market Research Study comments.",
      "ratings": [
        {
          "document_number": "2022-25611",
          "rating": 4
        }
      ]
    },
    {
      "id": 46,
      "llm_generated_query": true,
      "notes": nil,
      "query_terms": "Cancellation notice Advanced Aviation Advisory Committee meetings.",
      "ratings": [
        {
          "document_number": "2024-11872",
          "rating": 4
        }
      ]
    },
    {                             
      "id": 47,                   
      "llm_generated_query": true,
      "notes": nil,              
      "query_terms": "Form OPIC-50 comments due within 60 days.",
      "ratings": [                
        {                         
          "document_number": "2015-01879",
          "rating": 4
        }
      ]
    },
  ]

  def search_types
    [
      SearchType::LEXICAL,
      SearchType::LEXICAL_OPTIMIZED,
      SearchType::LEXICAL_OPTIMIZED_WITH_DECAY,
      SearchType::LEXICAL_OPTIMIZED_WITH_EXPANSIVE_DECAY,
    ].tap do |options|
      if Settings.feature_flags.open_search_version_supports_vectors
        options << SearchType::HYBRID
        options << SearchType::HYBRID_KNN_MIN_SCORE
      end
    end
  end


  def table_rows
    filtered_data.map do |evaluation_attr|
      TableRow.new(
        evaluation_attrs: evaluation_attr,
        rank_eval_responses_by_search_type: rank_eval_responses_by_search_type,
        search_types: search_types
      )
    end
  end

  private

  class TableRow
    extend Memoist
    attr_reader :query_terms, :notes, :ratings, :llm_generated_query

    def initialize(evaluation_attrs:, rank_eval_responses_by_search_type:, search_types:)
      @query_terms         = evaluation_attrs.fetch(:query_terms)
      @notes               = evaluation_attrs[:notes]
      @ratings             = evaluation_attrs.fetch(:ratings)
      @query_id            = evaluation_attrs.fetch(:id)
      @llm_generated_query = evaluation_attrs[:llm_generated_query] 
      @rank_eval_responses_by_search_type = rank_eval_responses_by_search_type
      @search_types = search_types
    end

    def metric_score(search_type)
      rank_eval_responses_by_search_type[search_type].
        fetch("details").
        fetch("query_#{query_id}").
        fetch("metric_score").
        round(ROUNDING_DIGITS)
    end
    memoize :metric_score

    def css_class
      if has_differences? # Highlight rows with differences in different shade
        'info'
      end
    end

    private

    attr_reader :rank_eval_responses_by_search_type, :query_id, :search_types

    def has_differences?
      first_metric_score = metric_score(search_types.first)
      search_types.any? do |search_type|
        metric_score(search_type) != first_metric_score
      end
    end

  end

  def rank_eval_responses_by_search_type
    search_types.each_with_object(Hash.new) do |search_type, hsh|
      hsh[search_type] =rank_eval_request(search_type)
    end
  end
  memoize :rank_eval_responses_by_search_type

  def filtered_data
    all_document_numbers = DATA.map{|x| x.fetch(:ratings)}.flatten.map{|y| y.fetch(:document_number)}
    available_document_numbers = Entry.where(document_number: all_document_numbers).pluck(:document_number)
    DATA.select do |evaluation|
      evaluation.fetch(:ratings).all?{|rating| available_document_numbers.include? rating.fetch(:document_number)} 
    end
  end

  ROUNDING_DIGITS = 2
  def rank_eval_request(search_type)
    response = Faraday.get("#{es_host}/#{index_name}/_rank_eval") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        "metric": {
          "precision": {
            "k": k_value,
            "relevant_rating_threshold": 1, #sets the rating threshold above which documents are considered to be "relevant"
            "ignore_unlabeled": true #controls whether unlabeled documents are ignored and neither count as relevant or irrelevant for scoring purposes
          }
        },
        "requests": (filtered_data.map.with_index do |attr, i|
          es_query = EsEntrySearch.new(
            conditions: {term: attr.fetch(:query_terms), search_type_id: search_type.id},
          ).send(search_type.is_hybrid_search ? :hybrid_search_options : :search_options).fetch(:query)
          if search_type.es_scoring_functions.present?
            es_query[:function_score][:functions] = search_type.es_scoring_functions
          end

          ratings = attr.fetch(:ratings).map do |rating_attrs|
            begin
              { 
                "_index": index_name,
                "_id": Entry.find_by_document_number!(rating_attrs.fetch(:document_number)).id.to_s,
                # "_id": (1..1000).to_a.sample.to_s,
                "rating": rating_attrs.fetch(:rating)
              }
            rescue
              raise rating_attrs.fetch(:document_number).inspect
            end
          end

          {
            "id": "query_#{attr.fetch(:id)}",                        
            "request": {                                              
                "query": es_query,
            }.tap do |request_params|
              if search_type.search_pipeline_configuration
                #NOTE: Without this, hybrid search results will be duplicative and inaccurate
                request_params.merge!("search_pipeline": search_type.search_pipeline_configuration)
              end 
            end,
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

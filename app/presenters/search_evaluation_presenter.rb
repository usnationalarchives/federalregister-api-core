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
    # {
    #   id: 9,
    #   query_terms: "mattresses from the Philippines",
    #   ratings: [
    #     {document_number: '2024-10567', rating: 4},
    #     {document_number: '2024-04322', rating: 4},
    #   ]
    # },
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
    # {
    #   id: 11,
    #   notes: "Example of a query for which there are minimially useful results in our corpus, but some things of tangential relevance",
    #   query_terms: "Grants for women out of prison",
    #   ratings: [
    #     {document_number: '2024-09614', rating: 1},
    #     {document_number: '2024-09795', rating: 1},
    #     {document_number: '2024-09797', rating: 1},
    #     {document_number: '2024-09796', rating: 1},
    #   ]
    # },
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
    # {
    #   id: 18,
    #   query_terms: 'CMS-2439-F',
    #   notes: "Example of a case where only one result is available",
    #   ratings: [
    #     {document_number: '2024-08085', rating: 4},
    #   ]
    # },
    # {
    #   id: 19,
    #   query_terms: 'May 10, 2024 and CMS and minimum nursing standards',
    #   ratings: [
    #     {document_number: '2024-08273', rating: 4},
    #   ]
    # },
    {
      id: 20,
      query_terms: 'Native American Early childhood Education infrastructure Funding',
      ratings: [
        {document_number: '2024-05573', rating: 4},
        {document_number: '2024-03631', rating: 3},
      ]
    },

    {
      "id": 21,
      "notes": "",
      "query_terms": "Chesapeake and Ohio Canal National Park meeting",
      "ratings": [
        {
          "document_number": "2024-06964",
          "rating": 4
        }
      ]
    },
    {
      "id": 22,
      "notes": "",
      "query_terms": "Large Power Transformers AD Order Korea",
      "ratings": [
        {
          "document_number": "2023-28946",
          "rating": 4
        }
      ]
    },
    {
      "id": 23,
      "notes": "",
      "query_terms": "Rescindment of HUD/HOU-55 Debt Collection System",
      "ratings": [
        {
          "document_number": "2024-02128",
          "rating": 4
        }
      ]
    },
    {
      "id": 24,
      "notes": "",
      "query_terms": "OPM information collection RI 38-47 comments",
      "ratings": [
        {
          "document_number": "2024-04350",
          "rating": 4
        }
      ]
    },
    {
      "id": 25,
      "notes": "",
      "query_terms": "IHS Mashantucket Pequot Tribal Nation PRCDA Expansion",
      "ratings": [
        {
          "document_number": "2024-01017",
          "rating": 4
        }
      ]
    },
    {
      "id": 26,
      "notes": "",
      "query_terms": "EIS weekly receipt and review schedule",
      "ratings": [
        {
          "document_number": "2024-06098",
          "rating": 4
        }
      ]
    },
    {
      "id": 27,
      "notes": "",
      "query_terms": "SEC Closed Meeting Topics February 1, 2024",
      "ratings": [
        {
          "document_number": "2024-01786",
          "rating": 4
        }
      ]
    },
    {
      "id": 28,
      "notes": "",
      "query_terms": "Fish and Wildlife Service information collection comments",
      "ratings": [
        {
          "document_number": "2024-05184",
          "rating": 4
        }
      ]
    },
    {
      "id": 29,
      "notes": "",
      "query_terms": "OFAC Specially Designated Nationals List Update",
      "ratings": [
        {
          "document_number": "2024-08350",
          "rating": 4
        }
      ]
    },
    {
      "id": 30,
      "notes": "",
      "query_terms": "Correction Notice for Task Force Comments Deadline",
      "ratings": [
        {
          "document_number": "2024-01010",
          "rating": 4
        }
      ]
    },
    {
      "id": 31,
      "notes": "",
      "query_terms": "BBC Studios commercial marine photography permit application",
      "ratings": [
        {
          "document_number": "2024-05263",
          "rating": 4
        }
      ]
    },
    {
      "id": 32,
      "notes": "",
      "query_terms": "USACE South Fork Wind project judicial review",
      "ratings": [
        {
          "document_number": "2024-07467",
          "rating": 4
        }
      ]
    },
    {
      "id": 33,
      "notes": "",
      "query_terms": "NIH Special Emphasis Panel Meeting Notice",
      "ratings": [
        {
          "document_number": "2024-02087",
          "rating": 4
        }
      ]
    },
    {
      "id": 34,
      "notes": "",
      "query_terms": "Search: Rural Business-Cooperative Service information collection OMB 0570-0065.",
      "ratings": [
        {
          "document_number": "2024-05431",
          "rating": 4
        }
      ]
    },
    {
      "id": 35,
      "notes": "",
      "query_terms": "Correcting amendment for Dix Avenue Bridge regulation",
      "ratings": [
        {
          "document_number": "2024-04273",
          "rating": 4
        }
      ]
    },
    {
      "id": 36,
      "notes": "",
      "query_terms": "Query: 2024 civil penalty inflation adjustments BOEM",
      "ratings": [
        {
          "document_number": "2024-01412",
          "rating": 4
        }
      ]
    },
    {
      "id": 37,
      "notes": "",
      "query_terms": "FDA Susceptibility Test Interpretive Criteria Annual Compilation",
      "ratings": [
        {
          "document_number": "2024-07495",
          "rating": 4
        }
      ]
    },
    {
      "id": 38,
      "notes": "",
      "query_terms": "Wind-down procedures and impacts on ACP",
      "ratings": [
        {
          "document_number": "2024-02093",
          "rating": 4
        }
      ]
    },
    {
      "id": 39,
      "notes": "",
      "query_terms": "\"MIAX Open-Close Report Fee Schedule Amendment\"",
      "ratings": [
        {
          "document_number": "2024-03646",
          "rating": 4
        }
      ]
    },
    {
      "id": 40,
      "notes": "",
      "query_terms": "Establishing Retirement Savings Lost and Found database",
      "ratings": [
        {
          "document_number": "2024-07968",
          "rating": 4
        }
      ]
    },
    {
      "id": 41,
      "notes": "",
      "query_terms": "Establishment of San Juan Islands MAC nominations",
      "ratings": [
        {
          "document_number": "2024-02939",
          "rating": 4
        }
      ]
    },
    {
      "id": 42,
      "notes": "",
      "query_terms": "Evaluate U.S. Fish and Wildlife Service Concessions",
      "ratings": [
        {
          "document_number": "2023-28829",
          "rating": 4
        }
      ]
    },
    {
      "id": 43,
      "notes": "",
      "query_terms": "DFAS Personal Check Cashing Agreement Notice",
      "ratings": [
        {
          "document_number": "2024-08475",
          "rating": 4
        }
      ]
    },
    {
      "id": 44,
      "notes": "",
      "query_terms": "Submit comments for IMLS reviewer forms",
      "ratings": [
        {
          "document_number": "2024-04411",
          "rating": 4
        }
      ]
    },
    {
      "id": 45,
      "notes": "",
      "query_terms": "USPTO Patent and Trademark Resource Center",
      "ratings": [
        {
          "document_number": "2024-04116",
          "rating": 4
        }
      ]
    },
    {
      "id": 46,
      "notes": "",
      "query_terms": "Regulation details for Revolution Wind Farm project",
      "ratings": [
        {
          "document_number": "2024-05992",
          "rating": 4
        }
      ]
    },
    {
      "id": 47,
      "notes": "",
      "query_terms": "File protest or motion to intervene",
      "ratings": [
        {
          "document_number": "2024-02033",
          "rating": 4
        }
      ]
    },
    {
      "id": 48,
      "notes": "",
      "query_terms": "Senior Loan Officer Opinion Survey extension inquiry",
      "ratings": [
        {
          "document_number": "2024-07089",
          "rating": 4
        }
      ]
    },
    {
      "id": 49,
      "notes": "",
      "query_terms": "Postal Service competitive product agreement comments due",
      "ratings": [
        {
          "document_number": "2024-04759",
          "rating": 4
        }
      ]
    },
    {
      "id": 50,
      "notes": "",
      "query_terms": "LSC regulation changes governing body requirements",
      "ratings": [
        {
          "document_number": "2024-07762",
          "rating": 4
        }
      ]
    },
    {
      "id": 51,
      "notes": "",
      "query_terms": "\"Idaho Clean Water Act section 401 certification\"",
      "ratings": [
        {
          "document_number": "2024-04046",
          "rating": 4
        }
      ]
    },
    {
      "id": 52,
      "notes": "",
      "query_terms": "\"Feedback on GSA/OAP-3 System of Records\"",
      "ratings": [
        {
          "document_number": "2024-03007",
          "rating": 4
        }
      ]
    },
    {
      "id": 53,
      "notes": "",
      "query_terms": "Stars and Stripes Media Organization rule revision",
      "ratings": [
        {
          "document_number": "2024-08527",
          "rating": 4
        }
      ]
    },
    {
      "id": 54,
      "notes": "",
      "query_terms": "Comment on 10 CFR part 72 renewal",
      "ratings": [
        {
          "document_number": "2024-07286",
          "rating": 4
        }
      ]
    },
    {
      "id": 55,
      "notes": "",
      "query_terms": "SEC order cancelling registrations of investment advisers",
      "ratings": [
        {
          "document_number": "2024-00941",
          "rating": 4
        }
      ]
    },
    {
      "id": 56,
      "notes": "",
      "query_terms": "Review State Highway-Rail Grade Crossing Action Plan",
      "ratings": [
        {
          "document_number": "2024-06511",
          "rating": 4
        }
      ]
    },
    {
      "id": 57,
      "notes": "",
      "query_terms": "Loan volume eligibility criteria for PLP lenders",
      "ratings": [
        {
          "document_number": "2024-03687",
          "rating": 4
        }
      ]
    },
    {
      "id": 58,
      "notes": "",
      "query_terms": "Comment request on IRS Form 4797",
      "ratings": [
        {
          "document_number": "2024-06383",
          "rating": 4
        }
      ]
    },
    {
      "id": 59,
      "notes": "",
      "query_terms": "Review schedule for National Cancer Institute panels",
      "ratings": [
        {
          "document_number": "2024-08285",
          "rating": 4
        }
      ]
    },
    {
      "id": 60,
      "notes": "",
      "query_terms": "FAA airworthiness directive for GE engines",
      "ratings": [
        {
          "document_number": "2024-05547",
          "rating": 4
        }
      ]
    },
    {
      "id": 61,
      "notes": "",
      "query_terms": "Extend comment period for Summer EBT rule",
      "ratings": [
        {
          "document_number": "2024-08369",
          "rating": 4
        }
      ]
    },
    {
      "id": 62,
      "notes": "",
      "query_terms": "CINTAC meeting registration and public comments",
      "ratings": [
        {
          "document_number": "2024-00196",
          "rating": 4
        }
      ]
    },
    {
      "id": 63,
      "notes": "",
      "query_terms": "Request termination of debarment for Brendon Gagne",
      "ratings": [
        {
          "document_number": "2024-02706",
          "rating": 4
        }
      ]
    },
    {
      "id": 64,
      "notes": "",
      "query_terms": "Neurological Disorders and Stroke Special Panel Meeting",
      "ratings": [
        {
          "document_number": "2024-05727",
          "rating": 4
        }
      ]
    },
    {
      "id": 65,
      "notes": "",
      "query_terms": "NMFS Pacific cod reallocation 2024 season",
      "ratings": [
        {
          "document_number": "2024-07483",
          "rating": 4
        }
      ]
    },
    {
      "id": 66,
      "notes": "",
      "query_terms": "PJM Interconnection L.L.C rate filings",
      "ratings": [
        {
          "document_number": "2024-02609",
          "rating": 4
        }
      ]
    },
    {
      "id": 67,
      "notes": "",
      "query_terms": "\"EPA ENERGY STAR Program ICR review\"",
      "ratings": [
        {
          "document_number": "2024-01805",
          "rating": 4
        }
      ]
    },

  ]

  def search_types
    [
      SearchType::LEXICAL,
      SearchType::LEXICAL_NO_DECAY,
      SearchType::HYBRID,
      SearchType::HYBRID_KNN_MIN_SCORE,
    ]
  end


  def table_rows
    filtered_data.map do |attr|
      TableRow.new(
        query_terms: attr.fetch(:query_terms),
        notes:       attr[:notes],
        ratings:     attr.fetch(:ratings),
        rank_eval_responses_by_search_type: rank_eval_responses_by_search_type,
        query_id:    attr.fetch(:id)
      )
    end
  end

  private

  class TableRow
    attr_reader :query_terms, :notes, :ratings

    def initialize(query_terms:, notes:, ratings:, rank_eval_responses_by_search_type:, query_id:)
      @query_terms        = query_terms
      @notes              = notes
      @ratings        = ratings
      @rank_eval_responses_by_search_type = rank_eval_responses_by_search_type
      @query_id = query_id
    end

    def metric_score(search_type)
      rank_eval_responses_by_search_type[search_type].
        fetch("details").
        fetch("query_#{query_id}").
        fetch("metric_score").
        round(ROUNDING_DIGITS)
    end

    private

    attr_reader :rank_eval_responses_by_search_type, :query_id

  end

  def rank_eval_responses_by_search_type
    search_types.each_with_object(Hash.new) do |search_type, hsh|
      hsh[search_type] =rank_eval_request(search_type)
    end
  end
  memoize :rank_eval_responses_by_search_type

  def filtered_data
    if Rails.env.development?
      DATA.select do |x|
        x.fetch(:ratings).all?{|x| x.fetch(:document_number).start_with?('2024')}
      end
    else
      DATA
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
            conditions: {term: attr.fetch(:query_terms), search_type_ids: [search_type.id]},
          ).send(search_type.is_hybrid_search ? :hybrid_search_options : :search_options).fetch(:query)
          query_customization = search_type.query_customization
          if query_customization
            es_query[:function_score][:functions] = []
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

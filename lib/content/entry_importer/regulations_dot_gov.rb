module Content::EntryImporter::RegulationsDotGov
  extend Content::EntryImporter::Utils
  extend ActiveSupport::Memoizable
  provides :checked_regulationsdotgov_at, :regulationsdotgov_id, :comment_url
  
  def checked_regulationsdotgov_at
    Time.now
  end
  
  def comment_url
    if regulationsdotgov_id.present?
      post_data = "5|0|6|http://www.regulations.gov/search/Regs/|446B4F0F2748178C5DF14A4C3603154A|gov.egov.erule.gwt.module.regs.client.service.SubmitCommentService|getSubmitCommentModel|java.lang.String|#{regulationsdotgov_id}|1|2|3|4|1|5|6|"
      
      begin
        resp = client.post("/search/Regs/submitComment", post_data, {"Content-Type" => 'text/x-gwt-rpc; charset=utf-8'})
        if resp.status == 200
          json = resp.body
          json.sub!(/^\/\/OK/, '')
  
          details = JSON::parse(json)[-3]
          if details.include?('is_comment')
            debug "found comment URL for #{entry.document_number}!"
            return "http://www.regulations.gov/search/Regs/home.html#submitComment?R=#{regulationsdotgov_id}"
          end
        end
      rescue Exception => e
        debug "error: #{e}"
      end
    end
    debug "no comment URL for #{entry.document_number}"
  end
  
  def regulationsdotgov_id
    doc_id = entry.document_number
    post_data = "5|0|20|http://www.regulations.gov/search/Regs/|F3D88F749695A7EE58F4F8F75C874853|gov.egov.erule.gwt.module.regs.client.service.SearchResultsService|getSearchResultsByRelevance|gov.egov.erule.gwt.module.regs.client.model.SearchQueryModel|java.lang.String|gov.egov.erule.gwt.module.regs.client.model.SearchQueryModel/2404117451|com.extjs.gxt.ui.client.data.RpcMap/3441186752|documentType|java.lang.String/2004016611|0|openForComments|false|viewResultsByDocket|searchFields|#{doc_id}|recordsPerPage|10|queryString|Ne=11+8+8053+8098+8074+8066+8084+1&Ntt=#{doc_id}&Ntk=All&Ntx=mode+matchall&N=0|1|2|3|4|2|5|6|7|1|8|6|9|10|11|12|10|13|14|-4|15|10|16|17|10|18|19|10|20|20|"
    
    begin
      resp = client.post("/search/Regs/searchResults", post_data, {"Content-Type" => 'text/x-gwt-rpc; charset=utf-8'})
      if resp.status == 200
        json = resp.body
        json.sub!(/^\/\/OK/, '')
  
        details = JSON::parse(json)[-3]
        sid_title_loc = details.index("sid")
        if sid_title_loc
          debug "found regulationsdotgov_id for #{entry.document_number}!"
          return details[sid_title_loc.to_i + 1]
        end
      end
    rescue Exception => e
      debug "error: #{e}"
    end
    debug "no regulationsdotgov_id for #{entry.document_number}"
  end
  memoize :regulationsdotgov_id
  
  private
  def client
    unless @client
      @client = Patron::Session.new
      @client.timeout = 10
      @client.base_url = "http://www.regulations.gov"
    end
    @client
  end
end
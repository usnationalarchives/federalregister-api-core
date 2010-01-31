namespace :data do
  namespace :extract do
    desc "Scrape regulations.gov for id, comment URL"
    task :regulationsdotgov_id => :environment do
      date = ENV['DATE_TO_IMPORT'].blank? ? Date.today : Date.parse(ENV['DATE_TO_IMPORT'])
      
      Entry.find_each(:conditions => {:publication_date => date}) do |entry|
        doc_id = entry.document_number
        post_data = "5|0|16|http://www.regulations.gov/search/Regs/|AB0B7193CC1148EFEEB8D5771D3EBF33|gov.egov.erule.gwt.module.regs.client.service.SearchResultsService|getSearchResultsByRelevance|gov.egov.erule.gwt.module.regs.client.model.SearchQueryModel|java.lang.String|gov.egov.erule.gwt.module.regs.client.model.SearchQueryModel/2404117451|com.extjs.gxt.ui.client.data.RpcMap/3441186752|searchFields|java.lang.String/2004016611|#{doc_id}|documentType|0|recordsPerPage|25|Ne=11+8+8053+8098+8074+8066+8084+1&Ntt=E9-14714&Ntk=All&Ntx=mode+matchall&N=0|1|2|3|4|2|5|6|7|1|8|3|9|10|11|12|10|13|14|10|15|16|"
                    "5|0|7|http://www.regulations.gov/search/Regs/|AB0B7193CC1148EFEEB8D5771D3EBF33|gov.egov.erule.gwt.module.regs.client.service.SearchResultsService|getSearchResultsByRelevance|gov.egov.erule.gwt.module.regs.client.model.SearchQueryModel|java.lang.String|N=0&Ne=11+8+8053+8098+8074+8066+8084+1&Ntt=E9-15277&Ntk=All&Ntx=mode+matchall|1|2|3|4|2|5|6|0|7|"
        sess = Patron::Session.new
        sess.timeout = 10
        sess.base_url = "http://www.regulations.gov"

        entry.checked_regulationsdotgov_at = Time.now
        begin
          resp = sess.post("/search/Regs/searchResults", post_data, {"Content-Type" => 'text/x-gwt-rpc; charset=utf-8'})
          if resp.status == 200
            json = resp.body
            json.sub!(/^\/\/OK/, '')

            details = JSON::parse(json)[-3]
            sid_title_loc = details.index("sid")
          
            if sid_title_loc
              sid = details[sid_title_loc.to_i + 1]
              entry.regulationsdotgov_id = sid
              puts "FOUND: #{doc_id} => #{sid}"
            
              if sid
                post_data = "5|0|6|http://www.regulations.gov/search/Regs/|446B4F0F2748178C5DF14A4C3603154A|gov.egov.erule.gwt.module.regs.client.service.SubmitCommentService|getSubmitCommentModel|java.lang.String|#{sid}|1|2|3|4|1|5|6|"
                resp = sess.post("/search/Regs/submitComment", post_data, {"Content-Type" => 'text/x-gwt-rpc; charset=utf-8'})

                json = resp.body
                json.sub!(/^\/\/OK/, '')

                details = JSON::parse(json)[-3]
                if details.include?('is_comment')
                  puts "can comment on #{sid}!"
                  entry.comment_url = "http://www.regulations.gov/search/Regs/home.html#submitComment?R=#{sid}"
                end
              end
            end
          else
            puts "Could not locate #{doc_id}"
          end
          entry.save(false)
        rescue => e
          puts e
        end
      end
    end
  end
end
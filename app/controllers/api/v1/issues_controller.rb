class Api::V1::IssuesController < ApiController

  def show
    cache_for 1.day

    respond_to do |wants|
      wants.json do
        begin
          date = params[:id] == "current" ? Issue.last.publication_date : Date.parse(params[:id])

          path = FileSystemPathManager.new(date).document_issue_json_toc_path

          if File.exist?(path)
            render file: path, layout: false
          else
            record_not_found
          end
        rescue Date::Error => e
          render :json => {:status => 400, :message => "Invalid Date Requested"}, :status => 400
        end
      end
    end
  end

end

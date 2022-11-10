class Admin::Issues::NotesController < AdminController
  before_action :set_issue

  def edit
    @issue = Issue.find_by(publication_date: params[:issue_id])
  end

  def update
    if @issue.update(issue_params)
      Sidekiq::Client.enqueue(IssueTocRegenerator, @issue.publication_date.to_s(:iso))
      redirect_to admin_issue_path(@issue), :flash => { :notice => "Note successfully updated" }
    else
      flash.now[:error] = @issue.errors.full_messages.to_sentence
      render :edit
    end
  end

  private

  def set_issue
    @issue = Issue.find_by(publication_date: params[:issue_id])
  end

  def issue_params
    _params = params.require(:issue).permit(:toc_note_title, :toc_note_text, :toc_note_active)
  end
end

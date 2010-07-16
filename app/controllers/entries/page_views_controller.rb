class Entries::PageViewsController < ApplicationController
  def create
    EntryPageView.create!(:entry_id => params[:id], :remote_ip => request.env['X-Real-IP'])
    render :nothing => true
  end
end
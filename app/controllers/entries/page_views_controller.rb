class Entries::PageViewsController < ApplicationController
  def create
    EntryPageView.create!(:entry_id => params[:id], :remote_ip => request.env['HTTP_X_FORWARDED_FOR'])
    render :nothing => true
  end
end
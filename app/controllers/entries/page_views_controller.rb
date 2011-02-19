class Entries::PageViewsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  def create
    remote_ip = request.env['HTTP_X_FORWARDED_FOR'] || ''
    remote_ip = remote_ip.split(/\s*,\s*/).last
    EntryPageView.create!(:entry_id => params[:id], :remote_ip => remote_ip)
    render :nothing => true
  end
end
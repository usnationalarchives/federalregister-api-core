class Entries::EmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
    @entry = Entry.find_by_document_number!(params[:document_number])
    @entry_email = @entry.entry_emails.new
  end
  
  def create
    @entry = Entry.find_by_document_number!(params[:document_number])
    @entry_email = @entry.entry_emails.new(params[:entry_email])

    remote_ip = request.env['HTTP_X_FORWARDED_FOR'] || ''
    remote_ip = remote_ip.split(/\s*,\s*/).last
    @entry_email.remote_ip = remote_ip
    
    if @entry_email.save
      redirect_to delivered_entry_email_url(@entry)
    else
      render :action => :new
    end
  end
  
  def delivered
    @entry = Entry.find_by_document_number!(params[:document_number])
  end
end
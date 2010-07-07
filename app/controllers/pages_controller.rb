class PagesController < ApplicationController
  def show
    render :action => params[:slug]
  end
end
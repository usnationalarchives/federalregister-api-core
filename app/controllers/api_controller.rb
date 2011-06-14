class ApiController < ApplicationController
  private
  def server_error(exception)
    notify_hoptoad(exception)
    render :json => {:status => 500, :message => "Internal Server Error"}, :status => 500
  end

  def record_not_found
    render :json => {:status => 404, :message => "Record Not Found"}, :status => 404
  end

  def method_not_allowed
    render :json => {:status => 405, :message => "Method Not Allowed"}, :status => 405
  end
end
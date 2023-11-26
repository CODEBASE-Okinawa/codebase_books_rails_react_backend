class Admin::RequestsController < ApplicationController
  def index
    @requests = RequestBook.where(status: "true")
    render json: @requests
  end

  def toggle
    request = RequestBook.find(params[:id])

    request.status = !request.status
    request.save

    # redirect_to admin_requests_path
    render json: request
  end
end

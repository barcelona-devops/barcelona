class EndpointsController < ApplicationController
  before_action :load_district
  before_action :load_endpoint, except: [:index, :create]

  def index
    endpoints = @district.endpoints
    render json: endpoints, fields: [:name, :public, :ssl_policy, :certificate_id]
  end

  def create
    endpoint = @district.endpoints.create!(permitted_params)
    render json: endpoint
  end

  def update
    @endpoint.update!(permitted_params)
    render json: @endpoint
  end

  def show
    render json: @endpoint
  end

  def destroy
    @endpoint.destroy!
    head 204
  end

  private

  def permitted_params
    params.permit(
      :name,
      :public,
      :certificate_id,
      :ssl_policy
    )
  end

  def load_endpoint
    @endpoint = @district.endpoints.find_by!(name: params[:id])
  end

  def load_district
    @district = District.find_by!(name: params[:district_id])
  end
end

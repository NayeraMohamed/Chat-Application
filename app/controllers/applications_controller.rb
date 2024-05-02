class ApplicationsController < ApplicationController
  # to bypass auth when requests are made from postman
  skip_before_action :verify_authenticity_token

  # GET /applications
  def index
    applications = Application.all
    render json: applications
  end

  # GET /applications/:token
  def show
    application = Application.find_by(token: params[:token])

    if application
      render json: application, status: :ok
    else
      render json: { error: 'Application not found' }, status: :not_found
    end
  end

  # POST /applications
  def create
    application = Application.new(application_params)
    if application.save
      render json: { token: application.token }, status: :created
    else
      render json: application.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::StaleObjectError
    render json: { error: "Another process updated this record. Please retry." }, status: :conflict

  end

  # PATCH /applications/:token
  def update
    application = Application.find_by(token: params[:token])
    if application.update(application_params)
      render json: application, status: :ok
    else
      render json: application.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::StaleObjectError
    render json: { error: "Another process updated this record. Please retry." }, status: :conflict

  end


  private

  def application_params
    params.require(:application).permit(:name)
  end
end

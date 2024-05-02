class ChatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_application

  # GET /applications/:token/chats
  def index
    chats = @application.chats
    chat_attributes = chats.map { |chat| { number: chat.number, messages_count: chat.messages_count } }
    render json: chat_attributes, status: :ok
  end

    # GET /applications/:token/chats/:number
    def show
      chat = @application.chats.find(params[:number])

      if chat
        render json: { number: chat.number, messages_count: chat.messages_count }, status: :ok
      else
        render json: { error: 'Chat not found' }, status: :not_found
      end
    end

  # POST /applications/:token/chats
  def create
    chat = @application.chats.build
    if chat.save
      render json: { number: chat.number }, status: :created
    else
      render json: chat.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::StaleObjectError
    render json: { error: "Another process updated this record. Please retry." }, status: :conflict

  end

  private
  def set_application
    @application = Application.find_by(token: params[:application_token])
    if @application.nil?
      render json: { error: "Application not found" }, status: :not_found
      return
    end
  end

  def chat_params
    params.require(:chat).permit(:number)
  end
end

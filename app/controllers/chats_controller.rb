class ChatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_application

  # GET /applications/:token/chats
  def index
    chats = @application.chats
    render json: chats
  end

    # GET /applications/:token/chats/:number
    def show
      chat = @application.chats.find(params[:number])

      if chat
        render json: chat, status: :ok
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

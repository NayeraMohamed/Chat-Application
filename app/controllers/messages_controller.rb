class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_application
  before_action :set_chat

  # GET /applications/:token/chats/:number/messages
  def index
    messages = @chat.messages
    render json: messages
  end

  # GET /applications/:token/chats/:number/messages/:number
  def show
    message = @chat.messages.find(params[:number])

    if message
      render json: message, status: :ok
    else
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  # /applications/:token/chats/:number/messages/search?body={search_query_here}
  def search
    query = params[:body]

    if query.present?
      messages = Message.search(query, fields: [:body])

      if messages.any?
        message_attributes = messages.map { |message| { number: message.number, body: message.body } }
        render json: message_attributes, status: :ok
      else
        render json: { error: 'No messages found' }, status: :not_found
      end
    else
      render json: { error: 'Body parameter required for searching' }, status: :bad_request
    end
  end

  # POST /applications/:token/chats/:number/messages
  def create
    message = @chat.messages.build(message_params)
    if message.save
      IndexMessageJob.perform_later(message) # Enqueue the job
      render json: { number: message.number }, status: :created
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  # PATCH /applications/:token/chats/:number/messages/:number
  def update
    message = @chat.messages.find(params[:number])

    if message.update(message_params)
      render json: message, status: :ok
    else
      render json: message.errors, status: :unprocessable_entity
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

  private
  def set_chat
    @chat = @application.chats.find_by(number: params[:chat_number])
    if @chat.nil?
      render json: { error: "Chat not found" }, status: :not_found
      return
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end

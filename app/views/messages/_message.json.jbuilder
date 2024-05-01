json.extract! message, :id, :number, :body, :chat_id, :created_at, :updated_at
json.url message_url(message, format: :json)

json.extract! chat, :id, :number, :application_id, :messages_count, :created_at, :updated_at
json.url chat_url(chat, format: :json)

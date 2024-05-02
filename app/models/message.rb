class Message < ApplicationRecord
  searchkick
  belongs_to :chat

  before_validation :assign_number, on: :create
  validates :number, presence: true, uniqueness: { scope: :chat_id }
  validates :body, presence: true
  after_create :increment_chat_messages_count


  private
  def increment_chat_messages_count
    chat.increment!(:messages_count)
  end

  private
  def assign_number
    # FIXME:messages_count isn't updated live
    self.number = chat.messages_count + 1
  end
end

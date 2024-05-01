class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages, dependent: :destroy

  before_validation :assign_number, on: :create
  validates :number, presence: true, uniqueness: { scope: :application_id }
  after_create :increment_application_chat_count


  private
  def increment_application_chat_count
    application.increment!(:chats_count)
  end

  private
  def assign_number
      self.number = (application.chats_count) + 1
  end
end

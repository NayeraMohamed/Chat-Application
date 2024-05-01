class Application < ApplicationRecord
    has_many :chats, dependent: :destroy

    validates :name, presence: true, uniqueness: true

    before_create :generate_token

    private

    def generate_token
      self.token = SecureRandom.hex(16)
    end
  end


class IndexMessageJob < ApplicationJob
    queue_as :default

    def perform(message)
      message.reindex
    end
  end

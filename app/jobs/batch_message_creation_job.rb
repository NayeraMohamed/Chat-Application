class BatchMessageCreationJob < ApplicationJob
    queue_as :default

    @batch_messages = []

    BATCH_SIZE = 100

    def perform(message_params)
      # Accumulate incoming messages
      @batch_messages << message

      if @batch_messages.size >= BATCH_SIZE
        save_batch_messages_and_index
      end
    end

    private

    def save_batch_messages_and_index
      ActiveRecord::Base.transaction do
        Message.create!(@batch_messages)
        # Index all messages in Elasticsearch
        Message.reindex
        # Clear the batch messages array after successful batch insertion
        @batch_messages.clear
      end
    rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Error saving batch messages: #{e.message}")
        retries -= 1
        if retries.positive?
          Rails.logger.error("Retrying in #{retry_delay} seconds...")
          sleep retry_delay
          retry
        else
          Rails.logger.error("Maximum retry attempts reached")
        end
      end
  end

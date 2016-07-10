module IntercomApp
  class WebhooksManager
    class CreationFailed < StandardError; end

    def create_webhooks(intercom_token: intercom_token)
      @intercom_token = intercom_token
      return unless required_webhooks.present?
      required_webhooks.each do |webhook|
        create_webhook(webhook) unless webhook_exists?(webhook[:topic])
      end
    end

    def destroy_webhooks(intercom_token: intercom_token)
      @intercom_token = intercom_token
      intercom_client.subscriptions.all.each do |webhook|
        intercom_client.subscriptions.delete(webhook.id) if is_required_webhook?(webhook)
      end

      @current_webhooks = nil
    end

    def recreate_webhooks!(intercom_token: intercom_token)
      @intercom_token = intercom_token
      destroy_webhooks(intercom_token: intercom_token)
      create_webhooks(intercom_token: intercom_token)
    end

    private

    def intercom_client
      @intercom_client ||= Intercom::Client.new(app_id: @intercom_token, api_key: '')
    end

    def required_webhooks
      IntercomApp.configuration.webhooks
    end

    def is_required_webhook?(webhook)
      required_webhooks.map{ |w| w[:url] }.include? webhook.url
    end

    def create_webhook(attributes)
      webhook = intercom_client.subscriptions.create(attributes)
      raise CreationFailed unless webhook.persisted?
      webhook
    end

    def webhook_exists?(topic)
      current_webhooks[topic]
    end

    def current_webhooks
      @current_webhooks ||= intercom_client.subscriptions.all.index_by(&:topic)
    end
  end
end

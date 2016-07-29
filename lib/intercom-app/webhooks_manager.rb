module IntercomApp
  class WebhooksManager
    class CreationFailed < StandardError; end

    def initialize(params)
      @intercom_token = params[:intercom_token]
    end

    def create_webhooks
      return unless required_webhooks.present?
      required_webhooks.each do |webhook|
        create_webhook(webhook) unless webhook_exists?(webhook[:topics])
      end
    end

    def destroy_webhooks
      intercom_client.subscriptions.all.each do |webhook|
        intercom_client.subscriptions.delete(webhook.id) if is_required_webhook?(webhook)
      end

      @current_webhooks = nil
    end

    def recreate_webhooks!
      destroy_webhooks
      create_webhooks
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
    end

    def webhook_exists?(topics)
      current_webhooks[topics]
    end

    def current_webhooks
      @current_webhooks ||= intercom_client.subscriptions.all.index_by(&:topics)
    end
  end
end

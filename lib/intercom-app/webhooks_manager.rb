module IntercomApp
  class WebhooksManager
    class CreationFailed < StandardError; end
    def initialize(params)
      @intercom_token = params[:intercom_token]
    end

    def create_webhooks_subscriptions
      return unless required_webhooks.present?
      required_webhooks.each do |webhook|
        create_webhook_subscription(webhook) unless webhook_subscription_exists?(webhook[:topics])
      end
    end

    def destroy_webhooks_subscriptions
      intercom_client.subscriptions.all.each do |webhook|
        intercom_client.subscriptions.delete(webhook.id) if is_required_webhook?(webhook)
      end

      @current_webhooks_subscriptions = nil
    end

    def recreate_webhooks_subscriptions!
      destroy_webhooks_subscriptions
      create_webhooks_subscriptions
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

    def create_webhook_subscription(attributes)
      add_hub_secret_to_subscription(attributes)
      webhook = intercom_client.subscriptions.create(attributes)
    end

    def webhook_subscription_exists?(topics)
      current_webhooks_subscriptions[topics]
    end

    def current_webhooks_subscriptions
      @current_webhooks_subscriptions ||= intercom_client.subscriptions.all.index_by(&:topics)
    end

    def add_hub_secret_to_subscription(attributes)
      attributes[:hub_secret] = IntercomApp.configuration.hub_secret if IntercomApp.configuration.hub_secret.present?
    end

  end
end

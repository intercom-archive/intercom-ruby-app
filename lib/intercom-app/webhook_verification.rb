module IntercomApp
  module WebhookVerification
    extend ActiveSupport::Concern

    included do
      before_action :verify_request
    end

    private
    def verify_request
      body = request.body.read
      return head :unauthorized unless hmac_valid?(body)
    end

    def hmac_valid?(payload_body)
      secret = IntercomApp.configuration.hub_secret
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload_body)
      Rack::Utils.secure_compare(signature, intercom_hmac)
    end

    def intercom_hmac
      request.headers['X-Hub-Signature']
    end

  end
end

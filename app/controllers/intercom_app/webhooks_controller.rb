module IntercomApp
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    include IntercomApp::WebhookVerification

    class IntercomApp::MissingWebhookJobDeclarationError < StandardError; end

    def receive
      webhook_job_klass.perform_later({app_id: app_id, webhook: webhook_params.to_h})
      head :no_content
    end

    private

    def webhook_params
      params.except(:controller, :action, :type)
    end

    def webhook_job_klass
      "#{webhook_type.sub('.','_').classify}Job".safe_constantize or raise IntercomApp::MissingWebhookJobDeclarationError
    end

    def webhook_type
      params[:type]
    end

    def app_id
      params[:app_id]
    end

  end
end

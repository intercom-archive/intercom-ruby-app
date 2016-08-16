require 'test_helper'

class IntercomApp::WebhooksManagerTest < ActiveSupport::TestCase

  setup do
    IntercomApp.configure do |config|
      config.webhooks = [
        {topics: ['users'], url: "https://example-app.com/webhooks/users"},
        {topics: ['conversation.user.created', 'conversation.user.replied'], url: "https://example-app.com/webhooks/conversations"},
      ]
    end

    @manager = IntercomApp::WebhooksManager.new(intercom_token: 'some-token')
  end

  teardown do
    IntercomApp.configuration = nil
  end

  test "#create_webhooks_subscriptions makes calls to create webhooks" do
    Intercom::Service::Subscription.any_instance.stubs(all: [])

    Intercom::Service::Subscription.any_instance.expects(:create).with(topics: ['users'], url: "https://example-app.com/webhooks/users")
    Intercom::Service::Subscription.any_instance.expects(:create).with(topics: ['conversation.user.created', 'conversation.user.replied'], url: "https://example-app.com/webhooks/conversations")

    @manager.create_webhooks_subscriptions
  end

  test "#create_webhooks_subscriptions makes calls to create webhooks with hub_secret" do
    IntercomApp.configure do |config|
      config.hub_secret = 'some-hash'
    end

    Intercom::Service::Subscription.any_instance.stubs(all: [])

    Intercom::Service::Subscription.any_instance.expects(:create).with(topics: ['users'], url: "https://example-app.com/webhooks/users", hub_secret: 'some-hash')
    Intercom::Service::Subscription.any_instance.expects(:create).with(topics: ['conversation.user.created', 'conversation.user.replied'], url: "https://example-app.com/webhooks/conversations", hub_secret: 'some-hash')

    @manager.create_webhooks_subscriptions
  end

  test "#recreate_webhooks_subscriptions! destroys all webhooks and recreates" do
    @manager.expects(:destroy_webhooks_subscriptions)
    @manager.expects(:create_webhooks_subscriptions)

    @manager.recreate_webhooks_subscriptions!
  end

  test "#destroy_webhooks_subscriptions makes calls to destroy webhooks" do
    Intercom::Service::Subscription.any_instance.stubs(:all).returns(Array.wrap(all_mock_webhooks.first))
    Intercom::Service::Subscription.any_instance.expects(:delete).with(all_mock_webhooks.first.id)

    @manager.destroy_webhooks_subscriptions
  end

  test "#destroy_webhooks_subscriptions does not destroy webhooks that do not have a matching url" do
    Intercom::Service::Subscription.any_instance.stubs(:all).returns([stub(url: 'http://something-or-the-other.com/webhooks/conversations', id: 7214109)])
    Intercom::Service::Subscription.any_instance.expects(:delete).never

    @manager.destroy_webhooks_subscriptions
  end

  private

  def all_mock_webhooks
    [
      stub(id: 1, url: "https://example-app.com/webhooks/conversations", topics: ['conversations']),
      stub(id: 2, url: "https://example-app.com/webhooks/users", topics: ['users']),
    ]
  end
end

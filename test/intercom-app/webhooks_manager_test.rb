require 'test_helper'

class IntercomApp::WebhooksManagerTest < ActiveSupport::TestCase

  setup do
    IntercomApp.configure do |config|
      config.webhooks = [
        {topics: ['users'], url: "https://example-app.com/webhooks/users"},
        {topics: ['conversations'], url: "https://example-app.com/webhooks/conversations"},
      ]
    end

    @manager = IntercomApp::WebhooksManager.new(intercom_token: 'some-token')
  end

  test "#create_webhooks makes calls to create webhooks" do
    Intercom::Service::Subscription.any_instance.stubs(all: [])

    expect_webhook_creation(['users'], "https://example-app.com/webhooks/users")
    expect_webhook_creation(['conversations'], "https://example-app.com/webhooks/conversations")

    @manager.create_webhooks
  end

  test "#recreate_webhooks! destroys all webhooks and recreates" do
    @manager.expects(:destroy_webhooks)
    @manager.expects(:create_webhooks)

    @manager.recreate_webhooks!
  end

  test "#destroy_webhooks makes calls to destroy webhooks" do
    Intercom::Service::Subscription.any_instance.stubs(:all).returns(Array.wrap(all_mock_webhooks.first))
    Intercom::Service::Subscription.any_instance.expects(:delete).with(all_mock_webhooks.first.id)

    @manager.destroy_webhooks
  end

  test "#destroy_webhooks does not destroy webhooks that do not have a matching url" do
    Intercom::Service::Subscription.any_instance.stubs(:all).returns([stub(url: 'http://something-or-the-other.com/webhooks/conversations', id: 7214109)])
    Intercom::Service::Subscription.any_instance.expects(:delete).never

    @manager.destroy_webhooks
  end

  private

  def expect_webhook_creation(topics, url)
    Intercom::Service::Subscription.any_instance.expects(:create).with(topics: topics, url: url)
  end

  def all_webhook_topics
    @webhooks ||=  ['users', 'conversations']
  end

  def all_mock_webhooks
    [
      stub(id: 1, url: "https://example-app.com/webhooks/conversations", topics: ['conversations']),
      stub(id: 2, url: "https://example-app.com/webhooks/users", topics: ['users']),
    ]
  end
end

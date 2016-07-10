require 'test_helper'

class IntercomApp::WebhooksManagerTest < ActiveSupport::TestCase

  setup do
    IntercomApp.configure do |config|
      config.webhooks = [
        {topic: 'users', url: "https://example-app.com/webhooks/users"},
        {topic: 'conversations', url: "https://example-app.com/webhooks/conversations"},
      ]
    end

    @manager = IntercomApp::WebhooksManager.new(intercom_token: 'some-token')
  end

  test "#create_webhooks makes calls to create webhooks" do
    Intercom::Service::Subscription.any_instance.stubs(all: [])

    expect_webhook_creation('users', "https://example-app.com/webhooks/users")
    expect_webhook_creation('conversations', "https://example-app.com/webhooks/conversations")

    @manager.create_webhooks
  end

  test "#create_webhooks when creating a webhook fails, raises an error" do
    Intercom::Service::Subscription.any_instance.stubs(all: [])
    webhook = stub(persisted?: false)
    Intercom::Service::Subscription.any_instance.stubs(create: webhook)

    assert_raise IntercomApp::WebhooksManager::CreationFailed do
      @manager.create_webhooks
    end
  end

  test "#create_webhooks when creating a webhook fails and the webhook exists, do not raise an error" do
    webhook = stub(persisted?: false)
    webhooks = all_webhook_topics.map{|t| stub(topic: t)}
    Intercom::Service::Subscription.any_instance.stubs(create: webhook, all: webhooks)

    assert_nothing_raised IntercomApp::WebhooksManager::CreationFailed do
      @manager.create_webhooks
    end
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

  def expect_webhook_creation(topic, url)
    stub_webhook = stub(persisted?: true)
    Intercom::Service::Subscription.any_instance.expects(:create).with(topic: topic, url: url).returns(stub_webhook)
  end

  def all_webhook_topics
    @webhooks ||=  ['users', 'conversations']
  end

  def all_mock_webhooks
    [
      stub(id: 1, url: "https://example-app.com/webhooks/conversations", topic: 'conversations'),
      stub(id: 2, url: "https://example-app.com/webhooks/users", topic: 'users'),
    ]
  end
end

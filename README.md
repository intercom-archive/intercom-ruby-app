Intercom Integration
===========

Intercom Application Rails engine and generator

Description
-----------
This gem includes a Rails Engine and generators for writing Rails applications using the Intercom API. The Engine provides a SessionsController and all the required code for authenticating with an app via OAuth.

Apply to become an Intercom Developer
--------------------------------
To create an Intercom application and get your `client_id` and `client_secret` you will need to create an [Intercom account](https://app.intercom.io) first.
Once your application is created you can apply for an OAuth application in the "App Settings >> OAuth" section.
Make sure you request read admin permission to use [omniauth-intercom](http://github.com/intercom/omniauth-intercom).
Installation
------------
To get started create a new rails app :

``` sh
# Create a new rails app
$ rails new my_intercom_app
$ cd my_intercom_app
```
Then add `intercom-app` to your Gemfile and bundle install :
`gem 'intercom-app', '>= 0.2.1'`
and run :
``` sh
$ bundle install
```

Now we are ready to run any of the intercom_app generators. The following section explains the generators and what they can do.


Generators
----------

### Default Generator

The default generator will run the `install`, `app_model`, and `home_controller` generators. This is the recommended way to start your app.

```sh
$ rails generate intercom_app --app_key <your_app_key> --app_secret <your_app_secret> --oauth_modal true
```
 **oauth_modal**:
   - If true you can authenticate with Intercom using a modal
   - If false you can authenticate with Intercom directly from the current tab


*Note that you will need to run rake db:migrate after this generator*



### Adding your own Intercom app to your Integration

If you wish to add Intercom's widget for your integration (which you definitely should!), we recommend that you configure [intercom-rails]("https://github.com/intercom/intercom-rails") independently.


### Install Generator

```sh
$ rails generate intercom_app:install

# or optionally with arguments:

$ rails generate intercom_app:install --app_key <intercom_client_id> --secret <intercom_client_secret> --oauth_modal true
```

*Note that you will need to run rake db:migrate after this generator*

You can update any of these settings later on easily, the arguments are simply for convenience.

The generator adds IntercomApp and the required initializers to the host Rails application.


### App Model Generator

```sh
$ rails generate intercom_app:app_model
```

The install generator doesn't create any database models for you and if you are starting a new app its quite likely that you will want one (most of our internally developed apps do!). This generator creates a simple app model and a migration. It also creates a model called `SessionStorage` which interacts with `IntercomApp::SessionRepository`. Check out the later section to learn more about `IntercomApp::SessionRepository`




### Home Controller Generator

```sh
$ rails generate intercom_app:home_controller
```

This generator creates an example home controller that is retrieving your user list and displays your users names.


### Controllers, Routes and Views

The last group of generators are for your convenience if you want to start overriding code included as part of the Rails engine. For example by default the engine provides a simple SessionController, if you run the `rails generate intercom_app:controllers` generator then this code gets copied out into your app so you can start adding to it. Routes and views follow the exact same pattern.


Managing App Keys and Secrets
-----------------

The `install` generator places your App credentials directly into the intercom_app initializer which is convenient and fine for development but once your app goes into production **your api credentials should not be in source control**. When we develop apps we keep our keys in environment variables so a production intercom_app initializer would look like this:

```ruby
IntercomApp.configure do |config|
  config.api_key = ENV['INTERCOM_CLIENT_APP_KEY']
  config.app_secret = ENV['INTERCOM_CLIENT_APP_SECRET']
  config.hub_secret = ENV['INTERCOM_WEBHOOK_HUB_SECRET']
  config.oauth_modal = false
end
```

Webhooks Subscriptions
----------------------

You can add your webhooks subscriptions to the `IntercomApp.config`. Subscriptions to your topics will be added on authentication callback.

```ruby
IntercomApp.configure do |config|
  config.webhooks = [
    {topics: ['users'], url: 'https://my-intercom-app.com/webhooks/users'},
    {topics: ['conversation.user.created', 'conversation.user.replied'], url: 'https://my-intercom-app.com/webhooks/conversations'},
    {topics: ['event.created'], url: 'https://my-intercom-app.com/webhooks/conversations', metadata: { event_names: events } }
  ]
end
```

**Important** You will need to request the `manage_webhooks` permissions from Intercom to receive webhooks from Intercom.


Connect to the Intercom API
----------------------
This gem includes the following libraries :

http://github.com/intercom/omniauth-intercom <= Simple rake middleware to authenticate your customers with Intercom
http://github.com/intercom/intercom-ruby <= Intercom Ruby API wrapper

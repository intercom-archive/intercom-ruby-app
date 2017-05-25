Intercom Integration
===========


**Warning: This project is not actively maintained and will be deprecated soon. If you are using it to build your integration please get in touch** 

Intercom Application Rails engine and generator

Description
-----------
This gem includes a Rails Engine and generators for writing Rails applications using the Intercom API. The Engine provides a SessionsController and all the required code for authenticating with an app via OAuth.

[Getting started with Intercom Integrations](https://developers.intercom.io/docs/integration-setup-guide)

Apply to become an Intercom Developer
-------------------------------------
To create an Intercom application, you will need to create an [Intercom account](https://app.intercom.io) first. When your application is created, apply for an OAuth access in the "App Settings >> OAuth" section, in order to get your `client_id` and `client_secret`:
- For the Redirect URL ensure that you add `/auth/intercom/callback` (e.g. `https://<YOUR_URL>:3000/auth/intercom/callback`).
- **Make sure you request the `read_single_admin` permission ("Read one admin at a time"), to use [omniauth-intercom](http://github.com/intercom/omniauth-intercom) to authenticate.**

Installation
------------
To get started create a new rails app :

``` sh
# Create a new rails app
$ rails new my_intercom_app
$ cd my_intercom_app
```
Then add `intercom-app` to your Gemfile and bundle install :
`gem 'intercom-app', '>= 0.2.6'`
and run :
``` sh
$ bundle install
```

Now we are ready to run any of the intercom_app generators. The following section explains the generators and what they can do.


Generators
----------

### Default Generator

The default generator will run the `install`, `app_model`, and `home_controller` generators.
** This is the recommended way to start your app. **

```sh
$ rails generate intercom_app --app_key <intercom_client_id> --app_secret <intercom_client_secret> --oauth_modal true
```
 **oauth_modal**:
   - If true you can authenticate with Intercom using a modal
   - If false you can authenticate with Intercom directly from the current tab

You can now run :

At this point you've finished the setup.
You can run:

```sh
rake db:migrate
rails s
```
If you visit `http://<YOUR_URL>:3000` you'll be able to complete the OAuth flow and receive an authentication token.

You can make calls to Intercom APIs using `@intercom_client` in all controllers that inherits from `IntercomApp::AuthenticatedController`. This `@intercom_client` variable is instantiated with the token associated to the current session.

[See intercom-ruby](https://github.com/intercom/intercom-ruby) for more informations about how to use the ruby client to call Intercom API.


![](https://github.com/intercom/intercom-ruby-app/raw/master/screenshot.png?raw=true)

### Adding your own Intercom app to your Integration

If you want to add Intercom's widget for your integration (which you definitely should!), we recommend that you configure [intercom-rails]("https://github.com/intercom/intercom-rails") independently.
### Install Generator

```sh
$ rails generate intercom_app:install

# or optionally with arguments:

$ rails generate intercom_app:install --app_key <intercom_client_id> --app_secret <intercom_client_secret> --oauth_modal true
```

*Note that you will need to run rake db:migrate after this generator*

You can update any of these settings later on easily, the arguments are simply for convenience.

The generator adds IntercomApp and the required initializers to the host Rails application.


### App Model Generator

```sh
$ rails generate intercom_app:app_model
```

The install generator doesn't create any database models for you and if you are starting a new app its quite likely that you will want one (most of our internally developed apps do!). This generator creates a simple `App` model and a migration. It also creates a model called `SessionStorage` which interacts with `IntercomApp::SessionRepository`. Check out the later section to learn more about `IntercomApp::SessionRepository`




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

Session storage
----------------------

Configure the `store_in_session_before_login` Proc to store parameters in session before OAuth.
```ruby
IntercomApp.configure do |config|
  # storing data in the session before the authentication helps you access them on the callback
  # params contains omniauth hash (https://github.com/intercom/omniauth-intercom)
  config.store_in_session_before_login = Proc.new do |session, params|
      session[:name] = params[:name]
      session[:third_party_admin_id] = params[:third_party_admin_id]
    end
  }
end
```


Callback Storage
----------------------

When customers authenticate your app against Intercom, the OAuth `token` and the `intercom_app_id` are stored in the `App` model.
To store custom data you simply need to add new attributes to `App` model by running a migration and configure the `callback_hash` Proc to return this custom data :

```shell
rails generate migration addNameAndThirdPartyAdminIdToApp
```

```ruby
IntercomApp.configure do |config|
  # retrieve previously stored in session params
  # response contains omniauth hash (https://github.com/intercom/omniauth-intercom)
  config.callback_hash = Proc.new { |session, response|
    {
      name: response[:name],
      third_party_admin_id: session[:admin_id]
    }
  }
end
```

Protecting controllers and accessing oAuth tokens and user data
---------------------------------------------------------------

You can ensure that some controllers are accessible only by users who authenticated your app against Intercom.
To do so, you controller must inherit from `AuthenticatedController`.

Further, if you want to access their token in those controllers, simply use `app_session[:intercom_token]`.
You can also directly use the [Intercom client library](https://github.com/intercom/intercom-ruby) via `@intercom_client`, e.g.
```ruby
module MyIntercomApp
  class MyController < AuthenticatedController

    def get
      print app_session[:intercom_token]
      @intercom_client.users.find(email: "bob@example.com")
    end

  end
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


Intercom-Wix
----------------------

The [intercom-wix](https://github.com/Skaelv/intercom-wix) app is an example of an integration generated with the `intercom-ruby-app`.

Connect to the Intercom API
----------------------
This gem includes the following libraries :

http://github.com/intercom/omniauth-intercom <= Simple rake middleware to authenticate your customers with Intercom
http://github.com/intercom/intercom-ruby <= Intercom Ruby API wrapper


## Pull Requests

- **Add tests!** Your patch won't be accepted if it doesn't have tests.

- **Document any change in behaviour**. Make sure the README and any other
  relevant documentation are kept up-to-date.

- **Create topic branches**. Don't ask us to pull from your master branch.

- **One pull request per feature**. If you want to do more than one thing, send
  multiple pull requests.

- **Send coherent history**. Make sure each individual commit in your pull
  request is meaningful. If you had to make multiple intermediate commits while
  developing, please squash them before sending them to us.

## Troubleshooting

  #### omniauth-intercom > omniauth-oauth2 dependency in v0.1.4

  From v0.1.4 of our `omniauth-intercom` gem we have defined our `omniauth-oauth2` dependency to allow any version from 1.2 on. If you relied on our Gemspec version config for `omniauth-oauth2` you can simply add `gem 'omniauth-oauth2', '~> 1.2'` to your Gemfile. This will ensure your `omniauth-oauth2` version is `1.2.x` again.

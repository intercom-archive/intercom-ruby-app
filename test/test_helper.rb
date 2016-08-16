# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/intercom_ruby_app_example/config/environment.rb",  __FILE__)
require 'rails/test_help'
require 'mocha/setup'
require 'byebug'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
require "#{File.dirname(__FILE__)}/generator_test_helper.rb"

class ActiveSupport::TestCase
  include GeneratorTestHelpers
end

def mock_intercom_omniauth
  request.env['omniauth.auth'] = { 'uid' => '1', 'credentials' => { 'token' => '1234='}, 'extra' => { 'raw_info' => { 'app' => { 'id_code' => 'abc123' } } } }  if request
end

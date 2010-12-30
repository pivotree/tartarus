# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.dirname(__FILE__) + "/rails_app/config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
end

def fake_controller_request
  stub('request',
       :env => {
         'HTTP_HOST' => 'test_host',
         'KEY_ONE' => 'key_one_value',
         'LOOOOOOOONG_KEY_TWO' => 'key_two_value',
         'rack.session' => { :id => '123123' },
         'rack.session.options' => {},
         'rack.request.cookie_hash' => {}
       },
       :method => 'post',
       :parameters => 'params',
       :format => 'html',
       :protocol => 'http://',
       :request_uri => '/my/uri')     
end

class LoggedException < ActiveRecord::Base
  include Tartarus::Logger
end

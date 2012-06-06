require 'veritabill'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class TestVeritabill < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_
end
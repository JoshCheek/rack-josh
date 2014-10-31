require 'rack/test'

class MockApp
  def initialize(return_values={})
    @status  = return_values.fetch :status,  200
    @headers = return_values.fetch :headers, {}
    @body    = return_values.fetch :body,    "the body"
  end

  attr_reader :provided_env
  def call(env)
    @provided_env = env
    [@status, @headers, [@body]]
  end
end

module MiddlewareSpecHelpers
  def request_for(*args, &block)
    Rack::MockRequest.new(
      Rack::Lint.new(
        described_class.new(*args, &block)
      )
    )
  end
end

RSpec.configure do |c|
  c.include MiddlewareSpecHelpers
end

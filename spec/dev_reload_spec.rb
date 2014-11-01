require 'spec_helper'
require 'rack/josh/dev_reload'

class Fixtures
  class Example1
    def before
    end
  end
  Example2  = Class.new
  ToRemove1 = Class.new
  ToRemove2 = Class.new
end

RSpec.describe Rack::Josh::DevReload do
  it 'takes a hash whose keys are constants to remove and values are files to load before the call' do
    mock_app = lambda { |e|
      expect(Fixtures::Example1.instance_methods false).to eq [:after]
      [200, {}, ['']]
    }
    request_for(MockApp.new, 'Fixtures::Example1' => 'fixtures/example1').get('/')
  end

  it 'blows up if told to require a file not in the loadpath' do
    expect { request_for(MockApp.new, 'Fixtures::Example2' => 'fixtures/not-a-thing').get('/') }
      .to raise_error /fixtures\/not-a-thing/
  end

  it 'can have keys which are arrays' do
    expect(Fixtures.constants).to include :ToRemove1
    expect(Fixtures.constants).to include :ToRemove2
    request_for(MockApp.new, ['Fixtures::ToRemove1', 'Fixtures::ToRemove2'] => []).get('/')
    expect(Fixtures.constants).to_not include :ToRemove1
    expect(Fixtures.constants).to_not include :ToRemove2
  end

  it 'can have values wich are arrays' do
    expect(Fixtures.constants).to_not include :Added1
    expect(Fixtures.constants).to_not include :Added2
    request_for(MockApp.new, [] => ['fixtures/added1', 'fixtures/added2']).get('/')
    expect(Fixtures.constants).to include :Added1
    expect(Fixtures.constants).to include :Added2
  end

  it 'returns whatever the app returns' do
    mock_app = MockApp.new status:  234,
                           headers: {'mock' => 'header'},
                           body:    "mock body"
    response = request_for(mock_app, {}).get('/')
    expect(response.status).to eq 234
    expect(response.headers['mock']).to eq 'header'
    expect(response.body).to eq 'mock body'
  end

  it 'can remove toplevel classes' do
    Object.const_set :ABC, Class.new
    request_for(MockApp.new, 'ABC' => []).get('/')
    expect(Object.constants).to_not include :ABC

    Object.const_set :ABC, Class.new
    request_for(MockApp.new, '::ABC' => []).get('/')
    expect(Object.constants).to_not include :ABC
  end
end

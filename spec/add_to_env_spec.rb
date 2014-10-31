require 'spec_helper'
require 'rack/josh/merge_with_env'

RSpec.describe Rack::Josh::MergeWithEnv do
  it 'merges the provided hash into the env' do
    mock_app = MockApp.new
    response = request_for(mock_app, {'a' => 'b'}).get('/')
    expect(mock_app.provided_env['REQUEST_METHOD']).to eq 'GET'
    expect(mock_app.provided_env['a']).to eq 'b'
  end

  it 'overrides the rack values unless the :default option is set' do
    mock_app = MockApp.new
    response = request_for(mock_app, {'REQUEST_METHOD' => 'WAT'}).get('/')
    expect(mock_app.provided_env['REQUEST_METHOD']).to eq 'WAT'

    mock_app = MockApp.new
    response = request_for(mock_app,
                           {'REQUEST_METHOD' => 'WAT'},
                           default: true
                          ).get('/')
    expect(mock_app.provided_env['REQUEST_METHOD']).to eq 'GET'

    mock_app = MockApp.new
    response = request_for(mock_app,
                           {'unique' => 'WAT'},
                           default: true
                          ).get('/')
    expect(mock_app.provided_env['unique']).to eq 'WAT'
  end

  it 'returns whatever the app returned' do
    mock_app = MockApp.new status:  234,
                           headers: {'mock' => 'header'},
                           body:    "mock body"
    response = request_for(mock_app, {}).get('/')
    expect(response.status).to eq 234
    expect(response.headers['mock']).to eq 'header'
    expect(response.body).to eq 'mock body'
  end

  it 'can take a block for dynamic values, merging these, as well' do
    mock_app = MockApp.new
    response = request_for(mock_app, {'a' => 'b'}) { {'c' => 'd'} }.get('/')
    expect(mock_app.provided_env['a']).to eq 'b'
    expect(mock_app.provided_env['c']).to eq 'd'
  end

  it 'passes the env to the block' do
    mock_app = MockApp.new
    e = nil
    response = request_for(mock_app, {}) { |env| e=env; {'c' => 'd'} }.get('/')
    expect(e.merge('c' => 'd')).to eq mock_app.provided_env
  end

  it 'overrides the hard-coded hash with the block values' do
    mock_app = MockApp.new
    response = request_for(mock_app, {'a' => 'b'}) { {'a' => 'c'} }.get('/')
    expect(mock_app.provided_env['a']).to eq 'c'
  end

  it 'respects defaults with the block, as well' do
    mock_app = MockApp.new
    response = request_for(mock_app, {}) { {'REQUEST_METHOD' => 'WAT'} }.get('/')
    expect(mock_app.provided_env['REQUEST_METHOD']).to eq 'WAT'

    mock_app = MockApp.new
    response = request_for(mock_app, {}, default: true) { {'REQUEST_METHOD' => 'WAT'} }.get('/')
    expect(mock_app.provided_env['REQUEST_METHOD']).to eq 'GET'

    mock_app = MockApp.new
    response = request_for(mock_app, {}, default: true) { {'unique' => 'WAT'} }.get('/')
    expect(mock_app.provided_env['unique']).to eq 'WAT'
  end
end

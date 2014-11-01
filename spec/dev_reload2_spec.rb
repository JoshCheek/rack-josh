require 'spec_helper'
require 'rack/josh/dev_reload2'

RSpec.describe Rack::Josh::DevReload2 do
  it 'takes a list of files/directories and reloads the constants they define when they change' do
    fixture_dir = File.expand_path 'fixtures', __dir__
    request     = request_for(MockApp.new, ['fixtures/file_to_reload'])

    # initial state of the world
    expect(Fixtures.constants).to_not include :FileToReload_a
    expect(Fixtures.constants).to_not include :FileToReload_b

    # first request
    File.write File.join(fixture_dir, 'file_to_reload.rb'),
               'Fixtures::FileToReload_a = Class.new
                ::ABC = 123
                class Fixtures
                  O = Object
                end
               '
    request.get('/')

    # intermediate state of the world
    expect(Fixtures.constants).to     include :FileToReload_a
    expect(Fixtures.constants).to_not include :FileToReload_b
    expect(Fixtures::O).to eq Object
    expect(ABC).to eq 123

    # second request
    File.write File.join(fixture_dir, 'file_to_reload.rb'),
               'Fixtures::FileToReload_b = Class.new'
    request.get('/')

    # final state of the world
    expect(Fixtures.constants).to_not include :FileToReload_a
    expect(Fixtures.constants).to     include :FileToReload_b
    expect(Fixtures.constants).to_not include :O
    expect(Object.constants).to_not   include :ABC
  end
end

# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/congress-api').to_s

RSpec.describe Congress::API do
  subject(:client) { described_class.new('test-key') }

  let(:conn) { instance_double(Faraday::Connection) }

  before { allow(Faraday).to receive(:new).and_return(conn) }

  it 'parses a successful JSON response into a hash' do
    response = instance_double(Faraday::Response, success?: true, body: '{"bills":[]}')
    allow(conn).to receive(:get).and_return(response)
    expect(client.get('/bill')).to eq('bills' => [])
  end

  it 'sends the api_key, format, and any extra params' do
    response = instance_double(Faraday::Response, success?: true, body: '{}')
    allow(conn).to receive(:get).and_return(response)
    client.get('/bill', { limit: 50 })
    expect(conn).to have_received(:get)
      .with('bill', hash_including(api_key: 'test-key', format: 'json', limit: 50))
  end

  it 'raises APIError on a non-success HTTP status' do
    response = instance_double(Faraday::Response, success?: false, status: 500, body: '')
    allow(conn).to receive(:get).and_return(response)
    expect { client.get('/bill') }.to raise_error(Congress::APIError)
  end

  it 'raises APIError when the connection fails' do
    allow(conn).to receive(:get).and_raise(Faraday::ConnectionFailed.new('boom'))
    expect { client.get('/bill') }.to raise_error(Congress::APIError)
  end
end

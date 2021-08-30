# frozen_string_literal: true

require "async/rspec"

require "async/http/internet"
require "async/http/endpoint"
require "async/websocket/client"

require "webmock"

WebMock.enable!

RSpec.describe WebMock do
  include_context Async::RSpec::Reactor

  after do
    WebMock.reset!
  end

  context "when using with Async::HTTP" do
    context "when the host is allowed" do
      before { WebMock.disable_net_connect!(allow: "example.com") }

      it "works" do
        expect do
          Async::HTTP::Internet.new.post("https://example.com")
        end.to_not raise_error
      end
    end

    context "when the host is not allowed" do
      before { WebMock.disable_net_connect! }

      it "works" do
        expect do
          Async::HTTP::Internet.new.post("https://example.com")
        end.to raise_error(WebMock::NetConnectNotAllowedError)
      end
    end
  end

  context "when using Async::WebSocket" do
    context "when the host is allowed" do
      before { WebMock.disable_net_connect!(allow: "example.com") }

      it "does not work" do
        endpoint = Async::HTTP::Endpoint.parse("https://example.com/websocket")

        expect do
          Async::WebSocket::Client.connect(endpoint)
        end.to raise_error(WebMock::NetConnectNotAllowedError)
      end
    end

    context "when the host is not allowed" do
      before { WebMock.disable_net_connect! }

      it "does not work" do
        endpoint = Async::HTTP::Endpoint.parse("https://example.com/websocket")

        expect do
          Async::WebSocket::Client.connect(endpoint)
        end.to raise_error(WebMock::NetConnectNotAllowedError)
      end
    end
  end
end

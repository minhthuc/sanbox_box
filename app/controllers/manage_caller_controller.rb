class ManageCallerController < ApplicationController
  require "net/http"
  require "json"
  require "uri"
  before_action :init_client

  def show
    # begin
    i = 0
    tmp = nil
    while i< 50
      endpoint = get_online_endpoint @client
      # byebug
      channels = get_channel endpoint
      i = i + 1
      if channels.length > 0
        begin
          for channel in channels
            detail = @client.channels_get channel
            tmp = detail
            if detail["state"] == "Ring"
              incomming_call_api detail
            elsif detail["state"] == "Up"
              anwser_call_api detail
            elsif detail.nil?
              hangup_call_api tmp
              byebug
            end
          end
        rescue
          byebug
        ensure
        end
      end
      sleep 1
      
    end
  end

  def get_online_endpoint client
    endpoint = client.endpoints_list.select do |element|
      element["state"] == "online"
    end
  end

  def get_channel endpoint
    channels = Array.new
    endpoint_have_channels = endpoint.select do |element|
      element["channel_ids"].length > 0
    end
    for item in endpoint_have_channels
      for channel in item["channel_ids"]
        channels.push channel
      end
    end
    channels
  end

  private

  def init_client
    @client = ARI::Client.new({:host => "27.118.16.210", :port => 8088, :username => "zammad", :password => "secret5"})
    # @ami = RubyAsterisk::AMI.new("27.118.16.212",8088)
  end

  def incomming_call_api call_details
    uri = URI.parse("http://cskh.ippay.vn:8002/api/v1/sipgate/in")
    http = Net::HTTP.new(uri.host, uri.port)
    header = {"Content-Type": "application/json"}
    request = Net::HTTP::Post.new uri.path, header
    request.basic_auth "longnt@ippay.vn", "Longnt@Zammad123"
    request.body = {
        "event": "newCall",
        "direction": "in",
        "from": call_details["connected"]["name"] + " " + call_details["connected"]["number"],
        "to": call_details["connected"]["name"] + " " + call_details["connected"]["number"],
        "callId": call_details["id"]
    }.to_json
    # byebug
    http.request(request)
  end

  def anwser_call_api call_details
    uri = URI.parse("http://cskh.ippay.vn:8002/api/v1/sipgate/in")
    http = Net::HTTP.new(uri.host, uri.port)
    header = {"Content-Type": "application/json"}
    request = Net::HTTP::Post.new uri.path, header
    request.basic_auth "longnt@ippay.vn", "Longnt@Zammad123"
    request.body = {
        "event": "answer",
        "direction": "in",
        "from": call_details["caller"]["name"] + " " + call_details["caller"]["number"],
        "to": call_details["connected"]["name"] + " " + call_details["connected"]["number"],
        "callId": call_details["id"]
    }.to_json
    # byebug

    http.request(request)
  end

  def hangup_call_api call_details
    uri = URI.parse("http://cskh.ippay.vn:8002/api/v1/sipgate/in")
    http = Net::HTTP.new(uri.host, uri.port)
    header = {"Content-Type": "application/json"}
    request = Net::HTTP::Post.new uri.path, header
    request.basic_auth "longnt@ippay.vn", "Longnt@Zammad123"
    request.body = {
        "event": "hangup",
        "direction": "in",
        "from": call_details["caller"]["name"] + " " + call_details["caller"]["number"],
        "to": call_details["connected"]["name"] + " " + call_details["connected"]["number"],
        "callId": call_details["id"]
    }.to_json
    # byebug

    http.request(request)
  end
end

class ManageCallerController < ApplicationController
  require "net/http"
  require "json"
  require "uri"
  before_action :init_client

  def show
    # begin
    i = 1
    tmp = nil
    while i < 50
      # endpoint = get_online_endpoint @client
      i = i + 1
      # begin
        channels = get_channel_direct @client
        if channels.length > 0
          for channel in channels
            detail = @client.channels_get channel
            if detail["state"] == "Ring"
              tmp = detail
              incomming_call_api detail
            elsif detail["state"] == "Up"
              tmp = detail
              anwser_call_api detail
              # elsif detaill.length == 0
            elsif tmp.length != 0 && detail.nil?
              byebug
              # else
            end
          end
        elsif !tmp.nil?
          hangup_call_api tmp
        end
      # rescue
      # end
      # elsif tmp.length > 0
      #   hangup_call_api tmp
    end
    sleep 1

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

  def get_channel_direct client
    client.channels_list
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
    # byebug
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

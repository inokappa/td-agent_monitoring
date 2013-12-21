#!/usr/bin/env ruby

require 'open-uri'
require 'erb'
require 'sinatra/reloader'
require 'multi_json'
require 'json'

class Getstatus 
  def parse_status(hostid,host)
    result = {}
    status_html = open("http://#{host}:24220/api/plugins.json").read
    parsed = JSON.parser.new(status_html).parse()
    type = parsed['plugins'][2]['type']
    rtc = parsed['plugins'][2]['retry_count']
    bql = parsed['plugins'][2]['buffer_queue_length']
    btqs = parsed['plugins'][2]['buffer_total_queued_size']
    if (rtc >= 10 or bql >= 256 or btqs >= 2147483648 )
      stats = "warning"
    else
      stats = "normally"
    end
    result[:hostid] = hostid
    result[:host] = host
    result[:type] = type
    result[:retry_count] = rtc
    result[:buffer_queue_length] = bql
    result[:buffer_total_queued_size] = btqs
    result[:stats] = stats
    return result
  end
  def raw_json(hostid,host)
    status_html = open("http://#{host}:24220/api/plugins.json").read
    parsed = MultiJson.load(status_html)
    return parsed
  end
end

get '/status' do
  all_result = []
  file = open("./list.txt")
  while text = file.gets do
    arr = text.split(",")
    chk = Getstatus.new()
    checked = chk.parse_status("#{arr[0]}","#{arr[1]}")
    all_result << checked
  end
  @result = all_result
  erb :index
end

get '/status/:hostid' do
  arr = []
  file = open("./list.txt")
  while text = file.gets do
    arr << text.split(",")
  end
  tdhost = arr.assoc("#{params[:hostid]}")
  host_result = []
  chk = Getstatus.new()
  checked = chk.parse_status("#{tdhost[0]}","#{tdhost[1]}")
  host_result << checked
  @result = host_result
  rawhash = chk.raw_json("#{tdhost[-1]}","#{tdhost[1]}")
  @rawjson = MultiJson.dump(rawhash, :pretty => true)
  #puts @rawjson
  erb :host , :layout => false
end

#huga = '{"plugins":[{"plugin_id":"object:3fa0135ac81c","type":"monitor_agent","output_plugin":false,"config":{"type":"monitor_agent","bind":"0.0.0.0","port":"24220"}},{"plugin_id":"object:3fa0147081d8","type":"forward","output_plugin":false,"config":{"type":"forward","port":"24224"}},{"plugin_id":"object:3fa0146a5f60","type":"forward","output_plugin":true,"buffer_queue_length":0,"buffer_total_queued_size":0,"retry_count":0,"config":{"type":"forward","buffer_type":"file","buffer_path":"/tmp/fluentd/buffer","flush_interval":"60s"}}]}'
#hoge = MultiJson.load(huga)
#hoge = MultiJson.dump(hoge, :pretty => true)
#puts hoge

#!/usr/bin/env ruby

require 'open-uri'
require 'erb'
require 'sinatra/reloader'
require 'multi_json'
require 'json'

class Getstatus 
  def get_status(host)
    status_html = open("http://#{host}:24220/api/plugins.json").read
    parsed = MultiJson.load(status_html)
    return parsed
  end
  def get_raw_json(host)
    status_html = open("http://#{host}:24220/api/plugins.json").read
    parsed = MultiJson.load(status_html)
    return parsed
  end
  def parse_json(hostid,host)
    result = []
    parsed = get_status(host)
    plugins = parsed['plugins']
    plugin_result = {}
    plugins.each do |plugin|
      type = plugin['type']
      plugin['retry_count'] != nil ? rtc = plugin['retry_count']: rtc = 'N/A'
      plugin['buffer_queue_length'] != nil ? bql = plugin['buffer_queue_length']: bql = 'N/A'
      plugin['buffer_queue_length'] != nil ? btqs = plugin['buffer_total_queued_size']: bql = 'N/A'
      if rtc != 'N/A'
        if (rtc >= 10 or bql >= 256 or btqs >= 2147483648 )
          stats = "warning"
        else
          stats = "normally"
        end
      else
        stats = "N/A"
      end
      plugin_result[:hostid] = hostid
      plugin_result[:host] = host
      plugin_result[:type] = type
      plugin_result[:retry_count] = rtc
      plugin_result[:buffer_queue_length] = bql
      plugin_result[:buffer_total_queued_size] = btqs
      plugin_result[:stats] = stats
      result << plugin_result
    end
    return result
  end
end

#get '/status' do
  all_result = []
  file = open("./list.txt")
  while text = file.gets do
    arr = text.split(",")
    chk = Getstatus.new()
    checked = chk.parse_json("#{arr[0]}","#{arr[1]}")
    all_result << checked
  end
  @result = all_result
  puts @result
  erb :index
#end

#get '/status/:hostid' do
  arr = []
  file = open("./list.txt")
  while text = file.gets do
    arr << text.split(",")
  end
  #tdhost = arr.assoc("#{params[:hostid]}")
  tdhost = arr.assoc("1")
  host_result = []
  chk = Getstatus.new()
  checked = chk.parse_json("#{tdhost[0]}","#{tdhost[1]}")
  host_result << checked
  @result = host_result
  rawhash = chk.get_raw_json("#{tdhost[1]}")
  @rawjson = MultiJson.dump(rawhash, :pretty => true)
  #puts @rawjson
  #erb :host , :layout => false
#end

#huga = '{"plugins":[{"plugin_id":"object:3fa0135ac81c","type":"monitor_agent","output_plugin":false,"config":{"type":"monitor_agent","bind":"0.0.0.0","port":"24220"}},{"plugin_id":"object:3fa0147081d8","type":"forward","output_plugin":false,"config":{"type":"forward","port":"24224"}},{"plugin_id":"object:3fa0146a5f60","type":"forward","output_plugin":true,"buffer_queue_length":0,"buffer_total_queued_size":0,"retry_count":0,"config":{"type":"forward","buffer_type":"file","buffer_path":"/tmp/fluentd/buffer","flush_interval":"60s"}}]}'
#hoge = MultiJson.load(huga)
#hoge = MultiJson.dump(hoge, :pretty => true)
#puts hoge

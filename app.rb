#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'erb'
require 'sinatra/reloader'

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
  chk = Getstatus.new()
  #
  host_result = []
  checked = chk.parse_status("#{tdhost[0]}","#{tdhost[1]}")
  host_result << checked
  @result = host_result
  erb :host, :layout => false
end

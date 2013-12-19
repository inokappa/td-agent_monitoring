#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'erb'
require 'sinatra/reloader'

get '/status' do
  file = open("./list.txt")
  statuses = []
  while text = file.gets do
    result = {}
    arr = text.split(",")
    status_url = "http://#{arr[0]}:24220/api/plugins.json"
    begin
      status_html = open("#{status_url}").read
    rescue Errno::ECONNREFUSED
      result[:host] = "#{arr[0]} not access"
      result[:stats] = "critical"
    else
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
      result[:host] = "#{arr[0]}"
      result[:type] = type
      result[:retry_count] = rtc
      result[:buffer_queue_length] = bql
      result[:buffer_total_queued_size] = btqs
      result[:stats] = stats
    end
  statuses << result
  @result = statuses
  end
  erb :index
end

get '/status/:host' do
  a = []
  result = {}
  status_url = "http://#{params[:host]}:24220/api/plugins.json"
  status_html = open("#{status_url}").read
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
  result[:host] = "#{params[:host]}"
  result[:type] = type
  result[:retry_count] = rtc
  result[:buffer_queue_length] = bql
  result[:buffer_total_queued_size] = btqs
  result[:stats] = stats
  a << result
  @result = a
  erb :host , :layout => false
end

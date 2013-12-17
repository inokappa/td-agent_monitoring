#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'erb'
require 'sinatra/reloader'

get '/status' do
  file = open("./list.txt")
  hoge = []
  while text = file.gets do
    result = {}
    arr = text.split(",")
    status_url = "http://#{arr[0]}:24220/api/plugins.json"
    begin
      status_html = open("#{status_url}").read
      rescue => exception
        case exception
        when OpenURI::HTTPError
          puts "status URL does not access."
          stats = "critical"
          exit 1
        end
    else
      parsed = JSON.parser.new(status_html).parse()
      host = "#{arr[0]}"
      type = parsed['plugins'][2]['type']
      rtc = parsed['plugins'][2]['retry_count']
      bql = parsed['plugins'][2]['buffer_queue_length']
      btqs = parsed['plugins'][2]['buffer_total_queued_size']
      if (rtc >= 1 and bql >= 1 and btqs >= 20000 )
        stats = "warning"
        flag << '1'
      else
        stats = "normally"
      end
      result[:host] = host
      result[:type] = type
      result[:retry_count] = rtc
      result[:buffer_queue_length] = bql
      result[:buffer_total_queued_size] = btqs
      result[:stats] = stats
    end
  hoge << result
  @result = hoge
  end
  erb :index
end

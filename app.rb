#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'erb'
require 'sinatra/reloader'

get '/status' do
  file = open("./list.txt")
  while text = file.gets do
    result = []
    arr = text.split(",")
    status_url = "http://#{arr[0]}:24220/api/plugins.json"
    begin
      status_html = open("#{status_url}").read
      rescue => exception
        case exception
        when OpenURI::HTTPError
          puts "status URL does not access."
          stats = "critical"
        end
    else
      parsed = JSON.parser.new(status_html).parse()
      bql = parsed["plugins"][4]['buffer_queue_length'].to_i
      btqs = parsed["plugins"][4]['buffer_total_queued_size'].to_i
      if (bql >= 3 and btqs >= 1000)
        stats = "warning"
      else
        stats = "healty"
      end
      result << "#{arr[0]}"
      result << bql
      result << btqs
      result << stats
    end
    p result
  end
  @result = result
  erb :index
end

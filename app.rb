#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'erb'
require 'sinatra/reloader'
require 'graphite-api'
#
# Function
#
$rtc_threshold = 10
$bql_threshold = 256
$btqs_threshold = 2147483648
$graphite_host = "Graphite_URL:2003"
#
# Methods
#
def get_td_status(url)
  status_url = "http://#{url}:24220/api/plugins.json"
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
    JSON.parser.new(status_html).parse()
  end
end
#
def post_graphite(host, type, rtc, bql, btqs)
  client = GraphiteAPI.new( graphite: $graphite_host )
  client.metrics(
    "#{host}.#{type}.retry_count"  => rtc,
    "#{host}.#{type}.buffer_queue_length"  => bql,
    "#{host}.#{type}.buffer_total_queued_size"  => btqs
  )
end
#
def check_stats(rtc, bql, btqs)
  if ( rtc >= $rtc_threshold or bql >= $bql_threshold or btqs >= $btqs_threshold )
    return "warning"
  else
    return "normally"
  end
end
#
def write_result(host, type, rtc, bql, btqs, stats)
  r = {}
  r[:host] = host
  r[:type] = type
  r[:retry_count] = rtc
  r[:buffer_queue_length] = bql
  r[:buffer_total_queued_size] = btqs
  r[:stats] = stats
  return r
end
#
# Main
#
get '/overview' do
  results = []
  file = open("./list.txt")
  while text = file.gets do
    result = {}
    arr = text.split(",")
    parsed = get_td_status("#{arr[0]}")
    configs = parsed['plugins'].size.to_i
    host = "#{arr[0]}".gsub(".", "-")
    #
    (0..(configs-1)).each do |config|
      type = parsed['plugins'][config]['type'] rescue nil
      rtc = parsed['plugins'][config]['retry_count'] rescue nil
      bql = parsed['plugins'][config]['buffer_queue_length'] rescue nil
      btqs = parsed['plugins'][config]['buffer_total_queued_size'] rescue nil
      #
      if ( rtc != nil and bql != nil and btqs != nil )
        # post to graphite
        post_graphite(host, type, rtc, bql, btqs) 
        stats = check_stats(rtc, bql, btqs)
      end
      result = write_result(host, type, rtc, bql, btqs, stats) 
      results << result
    end
    @overview = results
  end
  erb :index
end

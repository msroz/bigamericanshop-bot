# coding: utf-8

require "open-uri"
require "rubygems"
require "nokogiri"
require "pit"
require "pp"
require "json"
require "cgi"
require "net/http"
require 'nkf'
require 'twitter'
require 'logger'

URL = "http://bigamericanshop.com/blog/BAS/"
logger = Logger.new("./bot.log")

charset = nil
html = open(URL) do |f|
  charset = f.charset
  f.read
end
doc = Nokogiri::HTML.parse(html, nil, charset)
latest_date = doc.xpath('//p[@class="date"]').first.child.text

logger.info(latest_date)

rf = open('previous.txt', "r") # read
previous_date = rf.read || 'none'
rf.close
previous_date.chomp!
logger.info(previous_date)

if latest_date == previous_date then
  logger.info('not updated')
  exit 0
else
  logger.info('blog updated')
end


configure = Pit.get("bigamerican-bot")

client = Twitter::REST::Client.new do |conf|
  conf.consumer_key        = configure["consumer_key"]
  conf.consumer_secret     = configure["consumer_secret"]
  conf.access_token        = configure["access_token"]
  conf.access_token_secret = configure["access_token_secret"]
end

client.update("Blog updated!!! #{URL}")
logger.info('tweeted')
f = open('previous.txt', "w")
f.puts(latest_date)
f.close

#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'

require 'colorize'
require 'pry'
require 'csv'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko(url)
  Nokogiri::HTML(open(url).read) 
end

@BASE = 'http://www.consellgeneral.ad/ca/composicio-actual/consellers-generals'
url = @BASE

page = noko(url)
added = 0

page.css('div#content-core div.tileItem').drop(1).each do |p|
  p_url = p.at_css('h3 a/@href').text
  # binding.pry
  dep = noko(p_url)
  # partido = block.xpath('.//li/strong[contains(.,"Partido")]/../text()').text.strip
  # binding.pry
  data = { 
    id: p_url.split('/').last,
    name: dep.at_css('h1#parent-fieldname-title').text.strip,
    area: dep.at_css('div.electe span').text.strip,
    party: dep.at_css('div.grup span').text.strip,
    email: dep.at_css('div.email span').text.strip,
    birth_date: dep.at_css('div.datanaixement span').text.strip,
    image: dep.at_css('div.foto img/@src').text,
    start_date: dep.at_css('div.dataeleccio span').text.strip,
    term: 2015,
    source: p_url,
  }
  added += 1
  ScraperWiki.save_sqlite([:name, :term], data)
end
puts "  Added #{added} members"



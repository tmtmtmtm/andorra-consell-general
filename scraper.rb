#!/bin/env ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'scraperwiki'

# require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko(url)
  Nokogiri::HTML(open(url).read)
end

def datefrom(date)
  Date.parse(date)
end

def scrape_list(url)
  page = noko(url)
  added = 0

  page.css('div#content-core div.tileItem').drop(1).each do |p|
    p_url = p.at_css('h3 a/@href').text
    scrape_member(p_url)
    added += 1
  end
  puts "  Added #{added} members"
end

def scrape_member(url)
  dep = noko(url)
  data = {
    id: url.split('/').last,
    name: dep.at_css('h1#parent-fieldname-title').text.strip,
    area: dep.at_css('div.electe span').text.strip,
    party: dep.at_css('div.grup span').text.strip,
    email: dep.at_css('div.email span').text.strip,
    birth_date: datefrom(dep.at_css('div.datanaixement span').text.strip).to_s,
    image: dep.at_css('div.foto img/@src').text,
    election_date: datefrom(dep.at_css('div.dataeleccio span').text.strip).to_s,
    term: 2015,
    source: url,
  }
  puts data
  ScraperWiki.save_sqlite([:id, :term], data)
end

scrape_list 'http://www.consellgeneral.ad/ca/composicio-actual/consellers-generals'

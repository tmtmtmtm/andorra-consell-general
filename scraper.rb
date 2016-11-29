#!/bin/env ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'scraped'
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

class MemberListPage < Scraped::HTML
  field :member_urls do
    noko.css('div#content-core div.tileItem').drop(1).map do |p|
      p.at_css('h3 a/@href').text
    end
  end
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

list = 'http://www.consellgeneral.ad/ca/composicio-actual/consellers-generals'
page = MemberListPage.new(response: Scraped::Request.new(url: list).response)
page.member_urls.each do |url|
  scrape_member(url)
end


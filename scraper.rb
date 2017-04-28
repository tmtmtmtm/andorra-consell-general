#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'date'
require 'pry'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MemberListPage < Scraped::HTML
  field :member_urls do
    noko.css('div#content-core div.tileItem').drop(1).map do |p|
      p.at_css('h3 a/@href').text
    end
  end
end

list = 'http://www.consellgeneral.ad/ca/composicio-actual/consellers-generals'
page = MemberListPage.new(response: Scraped::Request.new(url: list).response)
page.member_urls.each do |url|
  data = MemberPage.new(response: Scraped::Request.new(url: url).response).to_h
  ScraperWiki.save_sqlite(%i[id term], data)
end

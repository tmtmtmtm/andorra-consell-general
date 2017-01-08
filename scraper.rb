#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'date'
require 'nokogiri'
require 'open-uri'
require 'scraped'
require 'scraperwiki'

# require 'pry'
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

class MemberPage < Scraped::HTML
  field :id do
    url.split('/').last
  end

  field :name do
    noko.at_css('h1#parent-fieldname-title').text.strip
  end

  field :area do
    noko.at_css('div.electe span').text.strip
  end

  field :party do
    noko.at_css('div.grup span').text.strip
  end

  field :email do
    noko.at_css('div.email span').text.strip
  end

  field :birth_date do
    Date.parse(noko.at_css('div.datanaixement span').text.strip).to_s
  end

  field :image do
    noko.at_css('div.foto img/@src').text
  end

  field :election_date do
    Date.parse(noko.at_css('div.dataeleccio span').text.strip).to_s
  end

  field :term do
    2015
  end

  field :source do
    url
  end
end

list = 'http://www.consellgeneral.ad/ca/composicio-actual/consellers-generals'
page = MemberListPage.new(response: Scraped::Request.new(url: list).response)
page.member_urls.each do |url|
  data = MemberPage.new(response: Scraped::Request.new(url: url).response).to_h
  ScraperWiki.save_sqlite(%i(id term), data)
end

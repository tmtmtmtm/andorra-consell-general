# frozen_string_literal: true

require 'scraped'

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

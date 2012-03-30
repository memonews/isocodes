require 'stringio'
require 'nokogiri'

module IsoCodes
  DEFAULT_PREFIXES = [
    "/usr",
    "/usr/local"
  ]

  def isocodes_prefix
    @prefix ||= DEFAULT_PREFIXES.detect do |prefix|
      File.exists?("#{prefix}/share/xml/iso-codes/iso_3166.xml")
    end
  end

  def isocodes_prefix=(prefix)
    @prefix = prefix
  end

  extend self
end

require File.dirname(__FILE__)+'/iso_codes/entity'
require File.dirname(__FILE__)+'/iso_codes/countries'
require File.dirname(__FILE__)+'/iso_codes/languages'

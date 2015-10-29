#!/usr/bin/env ruby1.9.3
# 2015, s.andres@syseleven.de
#
# Sensu Handler: sms
#
# This handler formats alerts as sms and sends them off to defined sms contacts
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'timeout'

# load sys11handler
require "#{File.dirname(__FILE__)}/sys11"

class Sms < Sys11Handler
  def handle
    if ENV['DEBUG'] == 'true'
      debug = true
      puts settings['notifications'].inspect
    end

    if settings['notifications']['sms'] == false
      # do nothing
      exit()
    end

    # Only send notifications between 0900 - 1659 when nine_to_five is true
    if settings['notifications']['sms']['nine_to_five'] == true
      if Time.now.hour.between?(10, 16)
        raise 'Not sending SMS. nine_to_five is enabled and it is not between 0900 and 1659.'
        exit()
      end
    end

    if not settings['notifications']['sms'].include? 'source' or settings['notifications']['sms'] == true
      raise 'Missing sms source address. Got no default'
    else
      source = settings['notifications']['sms']['source']
    end

    # cut check output to first 100 characters
    output = "#{@event['check']['output'][0..99]}"
    text = "#{status_to_string}: #{@event['client']['name']} #{@event['check']['name']} #{output}"

    settings['notifications']['sms']['targets'].each do |target|
      if debug
        ret = `echo txt2sms -s "#{source}" -d "#{target}" -m "#{text}" 2>&1`
      else
        ret = `txt2sms -s "#{source}" -d "#{target}" -m "#{text}" 2>&1`
      end
      if $?.success?
        puts "txt2sms successully send sms: #{target} (#{text}): #{ret}"
      else
        puts "txt2sms did not successully finish for #{target} (#{text}): #{ret}"
      end
    end
  end
end

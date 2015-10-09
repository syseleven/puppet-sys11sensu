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
    puts @notification_targets.inspect
    exit()


    if not @notification_targets.include? 'sms'
      bail('Missing sms-notification_target. Got no default')
    end

    # cut check output to first 100 characters
    output = "#{@event['check']['output'][0..99]}"
    text = "#{status_to_string}: #{@event['client']['name']} #{@event['check']['name']} #{output}"

    @notification_targets['sms'].each do |target|
      # TODO add actual command here
      puts "txt2sms -s FROM -d #{target} -m #{text}"
    end
  end
end

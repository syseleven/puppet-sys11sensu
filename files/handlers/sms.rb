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
    puts settings['notifications']['notification_targets'].inspect
    puts settings['notifications']['notification_types'].inspect
    puts @settings['notifications']['foo'].inspect
    exit()


    if not @notification_targets.include? 'sms'
      raise 'Missing sms-notification_target. Got no default'
    end

    # cut check output to first 100 characters
    output = "#{@event['check']['output'][0..99]}"
    text = "#{status_to_string}: #{@event['client']['name']} #{@event['check']['name']} #{output}"

    settings['notifications']['notification_targets']['sms'].each do |target|
      ret = `echo txt2sms -s FROM -d #{target} -m "#{text}" 2>&1`
      if not $?.success?
        puts "txt2sms did not successully finish for #{target} (#{text}): #{ret}"
      end
      puts ret
    end
  end
end

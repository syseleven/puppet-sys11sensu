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
  def filter_notification_states
    # This function takes a configured list as input and checks whether the
    # current event's status matches the configured list. If not, the event
    # is not further handled.
    
    notification_states = settings['notifications']['sms']['notification_states'] || [0, 1, 2, 3]
    # convert array values to integers
    notification_states = notification_states.map(&:to_i)

    # see if the latest service state was a valid state for the SMS handler to handle
    # (when a state changes from warning to ok, it may not send a SMS)
    if @event['action'] == 'resolve'
      if not notification_states.include? @event['check']['history'][-2].to_i
        bail("Not handling this event, because last known state (#{@event['check']['history'][-2]}) is not configured to be SMS worthy")
      end
    end

    if not notification_states.include? @event['check']['status'].to_i
      bail("Not handling this event, because current state (#{@event['check']['status']}) is not configured to be SMS worthy")
    end
  end

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
      if not Time.now.hour.between?(9, 16)
        raise 'Not sending SMS. nine_to_five is enabled and it is not between 0900 and 1659.'
      end
    end

    # filter notification states
    filter_notification_states

    if not settings['notifications']['sms'].include? 'source' or settings['notifications']['sms'] == true
      raise 'Missing sms source address. Got no default'
    else
      source = settings['notifications']['sms']['source']
    end

    output = "#{@event['check']['output']}"
    text = "#{status_to_string}: #{@event['client']['name']} #{@event['check']['name']} #{output}"
    # Cut the SMS text to 159 characters
    text = text[0..158]

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

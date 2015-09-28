#!/usr/bin/env ruby
#
# 2015, s.andres@syseleven.de
# 
# roughly taken from https://raw.githubusercontent.com/Yelp/sensu_handlers/0702ee3bb40b97fbfd8e2a9d7ca699f9fd451154/files/base.rb
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'

# Taken from https://github.com/flori/term-ansicolor/blob/e6086b7fddf53c53f8022acc1920f435e65b5e51/lib/term/ansicolor.rb#L60
COLOR_REGEX = /\e\[(?:(?:[349]|10)[0-7]|[0-9]|[34]8;5;\d{1,3})?m/

class Sys11Handler < Sensu::Handler
  def uncolorize(input)
    input.gsub(COLOR_REGEX, '')
  end

  def power_of_two?(x)
    while ( x % 2) == 0 and x > 1
      x /= 2
    end
    x==1
  end

  def filter_repeated
    if @event['check']['name'] == 'keepalive'
      # Keepalives are a special case because they don't emit an interval.
      # They emit a heartbeat every 20 seconds per
      # http://sensuapp.org/docs/0.12/keepalives
      interval = 20
    else
      interval      = @event['check']['interval'].to_i || 0
    end
    # [*alert_after*]
    # How long a check is allowed to be failing for before alerting (pagerduty/irc).
    # Can be an integer number of seconds, or an abbreviattion
    # Defaults to 0s, meaning sensu will alert as soon as the check fails.
    alert_after   = @event['check']['alert_after'].to_i || 0

    # [*realert_every*]
    # Number of event occurrences before the handler should take action.
    # For example, 10, would mean only re-notify every 10 fails.
    # This logic only occurs after the alert_after time has expired.
    # Defaults to -1 which means sensu will use exponential backoff.
    #

    if @event['check']['realert_every'].to_s.length > 0
      realert_every = @event['check']['realert_every'].to_i
    else
      realert_every = 10
    end

    # volatile checks repair themselfs, after a second check they always be
    # okay again, so if volatile is set to true, omit the recovery state
    # default: false
    if @event['check']['volatile'].to_s.length > 0
      volatile = @event['check']['volatile']
    else
      volatile = false
    end

    # enable this option for the following scenario:
    # multiple nodes have the same check (checking some shared object).
    # if this setting is true, only send multiple emails instead of one email per host
    # default: false
    if @event['check']['group'].to_s.length > 0
      group = @event['check']['group']
    else
      group = false
    end

    # [*occurrences*]
    #   Integer.  The number of event occurrences before the handler should take action. 
    # Default: 3
    if @event['check']['occurrences'].to_s.length > 0
      occurrences = @event['check']['occurrences'].to_i
    else
      occurrences = 3
    end
    occurrences_event = @event['occurrences']

    # only alert on this number of occurrence
    # default on all occurrences
    alert_on_occurrence = @event['check']['alert_on_occurrence'].to_i || -1
    # add occurrences setting to alert_on_occurrence threshold to have a meaningful effect
    alert_on_occurrence = alert_on_occurrence.to_i + occurrences.to_i

    if group
      begin
        clients = api_request(:GET, '/clients/').body
        clients = JSON.parse(clients)
        checks = []
        count = 0

        clients.each do |client|
          check = api_request(:GET, '/results/' + client['name'] + '/' + @event['check']['name']).body

          # match only existing checks and those who are not on ok-state
          if ! check.empty?
            count += 1
            check = JSON.parse(check)
            if check['check']['status'] != 0
              checks << check
            end
          end
        end

        # sort array of hashes by 'client' name in hash
        checks.sort_by! { |name| name['client'] }
        
        # when all services have non-ok-state
        if count == checks.length
          # only the first machine should send trigger an event
          if @event['client']['name'] != checks[0]['client']
            bail("Only handling check for #{checks[0]['client']} because you are filtering it by group")
          end
        end
      rescue => e
        puts 'Could not get group content'
        puts e.to_s
      end
    end

    
    initial_failing_occurrences = interval > 0 ? (alert_after / interval) : 0
    number_of_failed_attempts = occurrences - initial_failing_occurrences

    if @event['check']['name'] != 'keepalive'
      if occurrences_event < occurrences
        bail "not enough occurrences (#{occurrences_event} of #{occurrences})"
      elsif occurrences_event > occurrences and occurrences_event < realert_every
        bail "only handling every #{realert_every} occurrences, and we are at" \
          " #{occurrences_event}"
      end
    end

    if alert_on_occurrence > 0
      if occurrences != alert_on_occurrence and @event['action'] == 'create'
        bail "Only handling #{alert_on_occurrence} occurrences and we are at #{occurrences}"
      end
    end

    if volatile and @event['action'] == 'resolve'
      bail 'Do not handle resolve action for volatile check'
    end


    # Don't bother acting if we haven't hit the 
    # alert_after threshold
    if number_of_failed_attempts < 1
      bail "Not failing long enough, only #{number_of_failed_attempts} after " \
        "#{initial_failing_occurrences} initial failing occurrences"
    # If we have an interval, and this is a creation event, that means we are
    # an active check
    # Lets also filter based on the realert_every setting
    elsif interval > 0 and @event['action'] == 'create' 
      # Special case of exponential backoff
      if realert_every == -1
        # If our number of failed attempts is an exponent of 2
        if power_of_two?(number_of_failed_attempts)
          # Then This is our MOMENT!
          return nil
        else
          bail "not on a power of two: #{number_of_failed_attempts}"
        end
      elsif (number_of_failed_attempts - 1) % realert_every != 0 and occurrences_event > realert_every
        # Now bail if we are not in the realert_every cycle
        bail "only handling every #{realert_every} occurrences, and we are at" \
          " #{number_of_failed_attempts}"
      end
    end
  end
end

#!/usr/bin/env ruby1.9.3
#
# Sensu Handler: mailer
#
# This handler formats alerts as mails and sends them off to a pre-defined recipient.
#
# Copyright 2012 Pal-Kristian Hamre (https://github.com/pkhamre | http://twitter.com/pkhamre)
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'timeout'

class Stasher < Sensu::Handler

  def filter
    filter_disabled
    filter_dependencies
  end

  def handle
    stash = '/silence/' + @event['client']['name'] + '/' + @event['check']['name']
    if @event['action'].eql?('resolve') and stash_exists?(stash)
      begin
        timeout(2) do
          api_request(:DELETE, '/stash' + stash)
          puts "deleted stash " + stash
        end
      rescue Timeout::Error
        puts "timed out while attempting to delete the stash"
      end
    end
  end
end

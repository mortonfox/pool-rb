# frozen_string_literal: true

# Utility functions for working with Flickr.
# Author: Po Shan Cheah http://mortonfox.com

require 'flickraw'
require 'launchy'
require 'rbconfig'

module PoolRB
  # Functions for working with Flickr API.
  class Flickr
    API_KEY = 'db6b5b84eaba843fa20b0ce120d200c0'
    API_SECRET = 'dbfb3978910bfc79'

    MAX_RETRY = 5
    RETRY_WAIT = 0.5

    def initialize
      FlickRaw.api_key = API_KEY
      FlickRaw.shared_secret = API_SECRET
    end

    def sync_stdout
      save_sync = $stdout.sync
      $stdout.sync = true
      yield
    ensure
      $stdout.sync = save_sync if save_sync
    end
    private :sync_stdout

    def do_auth
      token = flickr.get_request_token
      auth_url = flickr.get_authorize_url token['oauth_token'], perms: 'write'

      Launchy.open(auth_url)
      sync_stdout { print 'Enter authorization code: ' }
      verify = gets.strip

      begin
        flickr.get_access_token token['oauth_token'], token['oauth_token_secret'], verify
        login = flickr.test.login
        puts "Authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}" if $DEBUG

        [flickr.access_token, flickr.access_secret]
      rescue EOFError, FlickRaw::FailedResponse, Timeout::Error, Errno::ENOENT, Errno::ETIMEDOUT, Errno::ECONNRESET => e
        raise "Flickr API authentication failed: #{e}"
      end
    end

    def set_auth(token, secret)
      flickr.access_token = token
      flickr.access_secret = secret
    end

    # Don't retry the following errors.
    PASSTHRU_ERRORS = Set.new(
      [
        3, # already in pool if adding photo / insufficient permission to remove photo
        4, # maximum number of pools
        5, # photo limit reached
        6, # added to pending queue
        7, # already in pending queue
        10 # maximum photos in pool
      ]
    ).freeze

    def self.flickr_retry
      retry_count = 0
      begin
        yield
      rescue FlickRaw::FailedResponse => e
        retry_count += 1
        if !PASSTHRU_ERRORS.include?(e.code) && retry_count <= MAX_RETRY
          sleep RETRY_WAIT
          retry
        end
        raise
      rescue EOFError, Timeout::Error, Errno::ENOENT, Errno::ETIMEDOUT, Errno::ECONNRESET
        retry_count += 1
        if retry_count <= MAX_RETRY
          sleep RETRY_WAIT
          retry
        end
        raise
      end
    end
  end
end

PoolRB::Flickr.new.do_auth if __FILE__ == $PROGRAM_NAME

__END__

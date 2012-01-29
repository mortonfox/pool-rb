require 'flickraw'
require 'rbconfig'

module PoolRB

  class Flickr

    API_KEY = 'db6b5b84eaba843fa20b0ce120d200c0'
    API_SECRET = 'dbfb3978910bfc79'

    MAX_RETRY = 5
    RETRY_WAIT = 0.5

    def initialize
      FlickRaw.api_key = API_KEY
      FlickRaw.shared_secret = API_SECRET
    end

    def is_mac?
      RbConfig::CONFIG['host_os'] =~ /darwin/i
    end
    private :is_mac?

    def sync_stdout
      save_sync = $stdout.sync
      $stdout.sync = true
      yield
    ensure
      $stdout.sync = save_sync if save_sync
    end
    private :sync_stdout

    def go_url url
      result = nil
      result = system "open '#{url}'" if is_mac?
      if not result
        puts "Open this URL in your browser to complete the authentication process:"
        puts url
      end
    end
    private :go_url

    def do_auth
      token = flickr.get_request_token
      auth_url = flickr.get_authorize_url token['oauth_token'], :perms => 'write'

      go_url auth_url
      sync_stdout { print "Enter authorization code: " }
      verify = gets.strip

      begin
        flickr.get_access_token token['oauth_token'], token['oauth_token_secret'], verify
        login = flickr.test.login
        puts "Authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}" if $DEBUG

        return [ flickr.access_token, flickr.access_secret ]
      rescue FlickRaw::FailedResponse => err
        fail "Flickr API authentication failed: #{err}"
      end
    end

    def set_auth token, secret
      flickr.access_token = token
      flickr.access_secret = secret
    end

    # Don't retry the following errors.
    PASSTHRU_ERRORS = {
      3 => true, # already in pool if adding photo / insufficient permission to remove photo
      4 => true, # maximum number of pools
      5 => true, # photo limit reached
      6 => true, # added to pending queue
      7 => true, # already in pending queue
      10 => true, # maximum photos in pool
    }

    def self.flickr_retry 
      retry_count = 0
      begin
        yield
      rescue FlickRaw::FailedResponse => err
        retry_count += 1
        if !PASSTHRU_ERRORS[err.code] and retry_count <= MAX_RETRY
          sleep RETRY_WAIT
          retry
        end
        raise
      rescue Timeout::Error => err
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

if __FILE__ == $0
  PoolRB::Flickr.new.do_auth
end

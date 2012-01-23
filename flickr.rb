require 'rubygems'
require 'flickraw'
require 'rbconfig'

module PoolRB

  API_KEY = 'db6b5b84eaba843fa20b0ce120d200c0'
  API_SECRET = 'dbfb3978910bfc79'

  class Flickr

    def initialize
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
      FlickRaw.api_key = API_KEY
      FlickRaw.shared_secret = API_SECRET

      token = flickr.get_request_token
      auth_url = flickr.get_authorize_url token['oauth_token'], :perms => 'write'

      go_url auth_url
      sync_stdout { print "Enter authorization code: " }
      verify = gets.strip

      begin
        flickr.get_access_token token['oauth_token'], token['oauth_token_secret'], verify
        login = flickr.test.login
        puts "Authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}" if $DEBUG
      rescue => err
        fail "Flickr API authentication failed: #{err}"
      end
    end

  end
end

if __FILE__ == $0
  PoolRB::Flickr.new.do_auth
end

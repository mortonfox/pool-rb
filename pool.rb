require 'rubygems'
require 'flickr'
require 'database'
require 'log'

module PoolRB

  class CleanPool

    SERVICE_NAME = 'pool'

    GROUPS = {
      25 => { :name => "1-25 Views", :id => '66969363@N00', :range => 0..25 },
      50 => { :name => "25-50 Views", :id => '55265535@N00', :range => 25..50 },
      75 => { :name => "50-75 Views", :id => '38541060@N00', :range => 50..75 },
      100 => { :name => "75-100 Views", :id => '45499242@N00', :range => 75..100 },
      200 => { :name => "150-200 Views", :id => '57008537@N00', :range => 150..200 },
    }

    def initialize testmode = false
      @db = Database.new
      @flickr = Flickr.new
      @log = Log.new 'pl'
      @testmode = testmode

      token, secret = @db.get_token SERVICE_NAME
      if token
        @flickr.set_auth token, secret
      else
        token, secret = @flickr.do_auth
        @db.add_token SERVICE_NAME, token, secret
      end
    end

    def getPhotos groupid, pagenum, pagelen
      Flickr::flickr_retry {
        flickr.groups.pools.getPhotos :group_id => groupid, :per_page => pagelen, :page => pagenum, :extras => 'views'
      }
    end

    # Remove photos that don't belong to the group.
    def rejectPhotos groupid, photos, range
      if @testmode
        puts "Test mode. Photos will not be removed."
        @log.puts "Test mode. Photos will not be removed."
      end

      i = 0
      photos.each { |photo|
        if !range.cover?(photo.views)
          i += 1
          url = "http://www.flickr.com/photos/#{photo.owner}/#{photo.id}";
          @log.puts "#{i}. <a href=\"#{url}\">#{photo.id}</a>: #{photo.title} by #{photo.ownername}, <b>#{photo.views}</b> views"
          puts "#{i}. Rejecting photo #{photo.id}..."
          
          next if @testmode

          begin
            Flickr::flickr_retry {
              flickr.groups.pools.remove :group_id => groupid, :photo_id => photo.id
            }
          rescue FlickRaw::FailedResponse => err
            warn "Failed to remove photo #{photo.id}: #{err.code} #{err.msg}"
            @log.puts "Failed to remove photo #{photo.id}: #{err.code} #{err.msg}"
          end
        end
      }
    end
  end
end

if __FILE__ == $0
end

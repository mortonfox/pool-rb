#!/usr/bin/env ruby

require_relative 'flickr'
require_relative 'database'
require_relative 'log'
require 'optparse'

module PoolRB

  class CleanPool

    SERVICE_NAME = 'pool'

    PAGELEN = 100

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

    def getPhotos groupid, pagenum
      Flickr::flickr_retry {
        flickr.groups.pools.getPhotos :group_id => groupid, :per_page => PAGELEN, :page => pagenum, :extras => 'views'
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
        views = photo.views.to_i
        if !range.cover?(views)
          i += 1
          url = "http://www.flickr.com/photos/#{photo.owner}/#{photo.id}";
          @log.puts "#{i}. <a href=\"#{url}\">#{photo.id}</a>: #{photo.title} by #{photo.ownername}, <b>#{views}</b> views"
          puts "#{i}. Rejecting photo #{photo.id}..."
          
          next if @testmode

          begin
            Flickr::flickr_retry {
              flickr.groups.pools.remove :group_id => groupid, :photo_id => photo.id
            }
            sleep 0.5
          rescue FlickRaw::FailedResponse => err
            warn "Failed to remove photo #{photo.id}: #{err.code} #{err.msg}"
            @log.puts "Failed to remove photo #{photo.id}: #{err.code} #{err.msg}"
          end
        end
      }
    end

    def processPage pagenum, group
      result = getPhotos group[:id], pagenum

      puts "=== Group #{group[:name]}: page #{pagenum} of #{result.pages} ==="
      @log.puts "<h2>Group #{group[:name]}: page #{pagenum} of #{result.pages}</h2>"

      rejectPhotos group[:id], result, group[:range]
    end

    # Clean the first (latest) page of each group.
    def cleanFirstPages
      GROUPS.each { |gkey, group|
        processPage 1, group
      }
    end

    # Clean random pages chosen from all the groups.
    def cleanRandomPages
      pagetotals = {}
      totalpages = 0
      GROUPS.each { |gkey, group|
        result = getPhotos group[:id], 1
        pagetotals[gkey] = result.pages
        totalpages += result.pages
      }

      loop do
        i = rand totalpages

        pagetotals.each { |gkey, pages|
          if i < pages
            processPage i+1, GROUPS[gkey]
            break
          end
          i -= pages
        }
      end
    end
  end
end

do_what = :first

opts = OptionParser.new { |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-r', '--random', 'Clean random pages chosen from all groups.') { 
    do_what = :random
  }
  opts.on('-f', '--first', 'Clean first (latest) page of every group.') { 
    do_what = :first
  }
  opts.on_tail('-h', '-?', '--help', 'Show this message') {
    puts opts
    exit
  }
}

begin
  opts.parse! ARGV
rescue => err
  warn "Error parsing command line: #{err}"
  warn opts
  exit 1
end

begin
  pool = PoolRB::CleanPool.new 
  if do_what == :first
    pool.cleanFirstPages
  else
    pool.cleanRandomPages
  end
rescue Interrupt
  warn "Interrupted! Exiting..."
end

# -- END --

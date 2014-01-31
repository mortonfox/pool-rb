#!/usr/bin/env ruby

# Script for cleaning Flickr views groups.
# Author: Po Shan Cheah http://mortonfox.com

unless Kernel.respond_to? :require_relative
  # Add require_relative shim for Ruby 1.8 compatibility.
  module Kernel
    def require_relative modname
      require File.join(File.dirname(__FILE__), modname)
    end
  end
end

require_relative 'flickr'
require_relative 'database'
require_relative 'log'
require 'optparse'

module PoolRB

  # Clean Flickr views groups that we manage.
  class CleanPool

    SERVICE_NAME = 'pool'

    PAGELEN = 100

    GROUPS = {
      25 => { :name => '1-25 Views', :id => '66969363@N00', :range => 0..25 },
      50 => { :name => '25-50 Views', :id => '55265535@N00', :range => 25..50 },
      75 => { :name => '50-75 Views', :id => '38541060@N00', :range => 50..75 },
      100 => { :name => '75-100 Views', :id => '45499242@N00', :range => 75..100 },
      200 => { :name => '150-200 Views', :id => '57008537@N00', :range => 150..200 },
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

    def get_photos groupid, pagenum
      Flickr.flickr_retry {
        flickr.groups.pools.getPhotos :group_id => groupid, :per_page => PAGELEN, :page => pagenum, :extras => 'views'
      }
    end

    # Remove photos that don't belong to the group.
    def reject_photos groupid, photos, range
      if @testmode
        puts 'Test mode. Photos will not be removed.'
        @log.puts 'Test mode. Photos will not be removed.'
      end

      i = 0
      photos.each { |photo|
        views = photo.views.to_i
        unless range.cover?(views)
          i += 1
          url = "http://www.flickr.com/photos/#{photo.owner}/#{photo.id}"
          @log.puts "#{i}. <a href=\"#{url}\">#{photo.id}</a>: #{photo.title} by #{photo.ownername}, <b>#{views}</b> views"
          puts "#{i}. Rejecting photo #{photo.id} (#{views} views) ..."

          next if @testmode

          begin
            Flickr.flickr_retry {
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

    def general_retry
      retry_count = 0
      begin
        yield
      rescue => err
        if retry_count < 3
          retry_count += 1
          puts "Error: #{err}. Retrying..."
          @log.puts "Error: #{err}. Retrying..."
          sleep 1
          retry
        end

        $stderr.puts "Error: #{err}"
        @log.puts "Error: #{err}"
      end
    end

    def process_page pagenum, group
      general_retry {
        result = get_photos group[:id], pagenum
        pages = result.pages

        puts "=== Group #{group[:name]}: page #{pagenum} of #{pages} ==="
        @log.puts "<h2>Group #{group[:name]}: page #{pagenum} of #{pages}</h2>"

        reject_photos group[:id], result, group[:range]
      }
    end

    def page_totals
      pagetotals = {}
      totalpages = 0
      GROUPS.each { |gkey, group|
        result = get_photos group[:id], 1
        pagetotals[gkey] = result.pages
        totalpages += result.pages
      }
      [ totalpages, pagetotals ]
    end

    # Clean the pages of each group in order from most recent to oldest.
    def clean_first_pages
      _, pagetotals = page_totals

      pagenum = 1
      loop {
        didwork = false
        GROUPS.each { |gkey, group|
          if pagenum <= pagetotals[gkey]
            process_page pagenum, group
            didwork = true
          end
        }
        break unless didwork
        pagenum += 1
      }
    end

    # Clean random pages chosen from all the groups.
    def clean_random_pages
      totalpages, pagetotals = page_totals

      loop do
        i = rand totalpages

        pagetotals.each { |gkey, pages|
          if i < pages
            process_page i + 1, GROUPS[gkey]
            break
          end
          i -= pages
        }
      end
    end
  end
end

do_what = :first

options = OptionParser.new { |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
  opts.on('-r', '--random', 'Clean random pages chosen from all groups.') {
    do_what = :random
  }
  opts.on('-f', '--first', 'Clean pages from newest to oldest of every group.') {
    do_what = :first
  }
  opts.on_tail('-h', '-?', '--help', 'Show this message') {
    puts opts
    exit
  }
}

begin
  options.parse! ARGV
rescue => err
  warn "Error parsing command line: #{err}"
  warn options
  exit 1
end

begin
  pool = PoolRB::CleanPool.new
  if do_what == :first
    pool.clean_first_pages
  else
    pool.clean_random_pages
  end
rescue Interrupt
  warn 'Interrupted! Exiting...'
end

# -- END --

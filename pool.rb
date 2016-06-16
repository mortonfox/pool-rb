#!/usr/bin/env ruby

# Script for cleaning Flickr views groups.
# Author: Po Shan Cheah http://mortonfox.com

require_relative 'flickr'
require_relative 'database'
require_relative 'log'
require 'optparse'

module PoolRB
  # Clean Flickr views groups that we manage.
  class CleanPool
    SERVICE_NAME = 'pool'.freeze

    PAGELEN = 100

    GROUPS = {
      25 => { name: '1-25 Views', id: '66969363@N00', range: 0..25 },
      50 => { name: '25-50 Views', id: '55265535@N00', range: 25..50 },
      75 => { name: '50-75 Views', id: '38541060@N00', range: 50..75 },
      100 => { name: '75-100 Views', id: '45499242@N00', range: 75..100 },
      200 => { name: '150-200 Views', id: '57008537@N00', range: 150..200 },
    }.freeze

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
        flickr.groups.pools.getPhotos group_id: groupid, per_page: PAGELEN, page: pagenum, extras: 'views'
      }
    end

    # Remove photos that don't belong to the group.
    # Returns the number of photos rejected.
    def reject_photos groupid, photos, range
      if @testmode
        puts 'Test mode. Photos will not be removed.'
        @log.puts 'Test mode. Photos will not be removed.'
      end

      reject_count = 0
      i = 0
      photos.each { |photo|
        views = photo.views.to_i
        next if range.cover?(views)

        i += 1
        url = "http://www.flickr.com/photos/#{photo.owner}/#{photo.id}"
        @log.puts "#{i}. <a href=\"#{url}\">#{photo.id}</a>: #{photo.title} by #{photo.ownername}, <b>#{views}</b> views"
        puts "#{i}. Rejecting photo #{photo.id} (#{views} views) ..."

        next if @testmode

        begin
          Flickr.flickr_retry {
            flickr.groups.pools.remove group_id: groupid, photo_id: photo.id
          }
          reject_count += 1
          sleep 0.5
        rescue FlickRaw::FailedResponse => err
          warn "Failed to remove photo #{photo.id}: #{err.code} #{err.msg}"
          @log.puts "Failed to remove photo #{photo.id}: #{err.code} #{err.msg}"
        end
      }
      reject_count
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

        warn "Error: #{err}"
        @log.puts "Error: #{err}"
      end
    end

    # Cleans up one page of a Flickr group.
    # Returns an array: [the number of photos rejected, the group page count]
    def process_page pagenum, group
      general_retry {
        result = get_photos group[:id], pagenum
        pages = result.pages

        puts "=== Group #{group[:name]}: page #{pagenum} of #{pages} ==="
        @log.puts "<h2>Group #{group[:name]}: page #{pagenum} of #{pages}</h2>"

        reject_count = reject_photos group[:id], result, group[:range]

        [reject_count, pages]
      }
    end

    # Returns a hash of { group key => number of pages in group }
    def page_totals
      Hash[GROUPS.map { |gkey, group|
        result = get_photos group[:id], 1
        [gkey, result.pages]
      }]
    end

    # Clean the pages of each group in order from most recent to oldest.
    def clean_first_pages
      pagetotals = page_totals

      pagenum = 1
      loop {
        didwork = false

        # For each page number, process all the groups.
        GROUPS.each { |gkey, group|
          next if pagenum > pagetotals[gkey]

          loop_number = 1

          # Loop until this page is clean. The reason for needing this loop is
          # removing photos from a page brings in more photos, which will need
          # to be checked too, from the next page.
          loop {
            reject_count, pages = process_page pagenum, group
            break if reject_count == 0

            # Number of pages in this group may have gone down after photo
            # removal.
            pagetotals[gkey] = pages

            loop_number += 1
            puts "Round #{loop_number}..."
            @log.puts "Round #{loop_number}..."
          }

          didwork = true
        }

        # If no page was checked, then the page number is already beyond all
        # the groups so we can stop.
        break unless didwork

        pagenum += 1
      }
    end

    # Clean random pages chosen from all the groups.
    def clean_random_pages
      pagetotals = page_totals
      totalpages = pagetotals.values.reduce(:+)

      loop do
        puts "Total pages = #{totalpages}"

        # Pick a random page from all the pages.
        i = rand totalpages

        pagetotals.each { |gkey, pages|
          # Find the group that the chosen page is in.
          if i < pages
            _, pages = process_page i + 1, GROUPS[gkey]

            # Number of pages in this group may have gone down after photo
            # removal.
            pagetotals[gkey] = pages
            totalpages = pagetotals.values.reduce(:+)
            break
          end
          i -= pages
        }
      end
    end
  end
end

def parse_cmdline
  do_what = :first

  options = OptionParser.new { |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

    opts.on('-r', '--random', 'Clean random pages chosen from all groups.') {
      do_what = :random
    }

    opts.on('-f', '--first', 'Clean pages from newest to oldest of every group. (default)') {
      do_what = :first
    }

    opts.on('-h', '-?', '--help', 'Show this message') {
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

  do_what
end

do_what = parse_cmdline

pool = PoolRB::CleanPool.new

begin
  if do_what == :first
    pool.clean_first_pages
  else
    pool.clean_random_pages
  end
rescue Interrupt
  warn 'Interrupted! Exiting...'
end

# -- END --

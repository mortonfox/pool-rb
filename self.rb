#!/usr/bin/env ruby

unless Kernel.respond_to? :require_relative
  module Kernel
    def require_relative modname
      require File.join(File.dirname(__FILE__), modname)
    end
  end
end

require_relative 'flickr'
require_relative 'database'
require_relative 'log'

module PoolRB

  class SelfPool

    SERVICE_NAME = 'self'

    GROUPS = [
      { :name => "1-25 Views", :id => '66969363@N00', :range => 1..24 },
      { :name => "25-50 Views", :id => '55265535@N00', :range => 25..49 },
      { :name => "50-75 Views", :id => '38541060@N00', :range => 50..74 },
      { :name => "75-100 Views", :id => '45499242@N00', :range => 75..99 },
      { :name => "100-150 Views", :id => '25694047@N00', :range => 100..149 },
      { :name => "150-200 Views", :id => '57008537@N00', :range => 150..199 },

      { :name => "Views: 25", :id => '14813384@N00', :range => 25..49 },
      { :name => "Views: 50", :id => '63923506@N00', :range => 50..74 },
      { :name => "Views: 75", :id => '26651003@N00', :range => 75..99 },
      { :name => "Views: 100", :id => '37045109@N00', :range => 100..199 },
      { :name => "Views: 200", :id => '35419517@N00', :range => 200..299 },
      { :name => "Views: 300", :id => '76852794@N00', :range => 300..399 },
      { :name => "Views: 400", :id => '97866666@N00', :range => 400..499 },
      { :name => "Views: 500", :id => '32266655@N00', :range => 500..599 },
      { :name => "Views: 600", :id => '50687206@N00', :range => 600..699 },
      { :name => "Views: 700", :id => '65104419@N00', :range => 700..799 },
      { :name => "Views: 800", :id => '87608476@N00', :range => 800..899 },
      { :name => "Views: 900", :id => '79303709@N00', :range => 900..999 },
      { :name => "Views: 1000", :id => '85342170@N00', :range => 1000..1249 },
      { :name => "Views: 1250", :id => '66448677@N00', :range => 1250..1499 },
      { :name => "Views: 1500", :id => '18374590@N00', :range => 1500..1749 },
      { :name => "Views: 1750", :id => '25661400@N00', :range => 1750..1999 },
      { :name => "Views: 2000", :id => '44588749@N00', :range => 2000..2999 },
      { :name => "Views: 3000", :id => '10386539@N00', :range => 3000..3999 },
      { :name => "Views: 4000", :id => '69218008@N00', :range => 4000..4999 },
      { :name => "Views: 5000", :id => '52498228@N00', :range => 5000..9999 },
      { :name => "Views: 10000", :id => '28114976@N00', :range => 10000..24999 },
      { :name => "Views: 25000", :id => '665334@N25', :range => 25000..999999 },

      { :name => " 100+ Views OR 10+ Favorites", :id => '53758961@N00', :range => 100..99999 },
      { :name => "50 Views - 100", :id => '33128095@N00', :range => 50..99 },
      { :name => "50 to 99 views", :id => '47017726@N00', :range => 50..99 },
      { :name => "Centurian Club", :id => '38475367@N00', :range => 100..199 },
      { :name => "200 Views", :id => '12476408@N00', :range => 200..299 },    
#      { :name => "200 Views (freeminded)", :id => '23348528@N00', :range => 200..299 },
      { :name => "100 Views", :id => '49688781@N00', :range => 100..199 },
      { :name => "100 Views - 200", :id => '49864370@N00', :range => 100..199 },
      { :name => "300 Views - 499", :id => '94294471@N00', :range => 300..499 },
      { :name => "400 Views", :id => '73162739@N00', :range => 400..499 },
      { :name => "500 Views", :id => '29315372@N00', :range => 500..599 },
      { :name => "600 Views", :id => '93769266@N00', :range => 600..999 },
      { :name => "1000 Views", :id => '83435940@N00', :range => 1000..1499 },
      { :name => "1500 Views", :id => '95702907@N00', :range => 1500..1999 },
      { :name => "2000 Views", :id => '74001424@N00', :range => 2000..2499 },
      { :name => "2500 Views", :id => '22486783@N00', :range => 2500..3999 },
      { :name => "4000 Views", :id => '57817661@N00', :range => 4000..4999 },
      { :name => "5000 Views", :id => '36646466@N00', :range => 5000..7999 },
      { :name => "8000 Views", :id => '84118708@N00', :range => 8000..9999 },
      { :name => "10000 Views", :id => '48137763@N00', :range => 10000..19999 },
      { :name => "20000 Views", :id => '76541493@N00', :range => 20000..29999 },
      { :name => "30000 Views", :id => '20944073@N00', :range => 30000..39999 },
      { :name => "40000 Views", :id => '10486925@N00', :range => 40000..49999 },
      { :name => "50000 Views", :id => '47292426@N00', :range => 50000..99999 },
      { :name => "100000 Views", :id => '83246564@N00', :range => 100000..999999 },

      { :name => "Views: 7-25", :id => '54402757@N00', :range => 7..25 },
      { :name => "Views: 26-50", :id => '54083170@N00', :range => 26..50 },
      { :name => "Views: 51-75", :id => '25553907@N00', :range => 51..75 },
      { :name => "Views: 76-100", :id => '76213832@N00', :range => 76..100 },
      { :name => "Views: 101-200", :id => '37847006@N00', :range => 101..200 },
      { :name => "Views: 201-300", :id => '23297148@N00', :range => 201..300 },
      { :name => "Views: 301-400", :id => '51348184@N00', :range => 301..400 },
      { :name => "Views: 401-500", :id => '36708499@N00', :range => 401..500 },
      { :name => "Views: 501-600", :id => '82555169@N00', :range => 501..600 },
      { :name => "Views: 601-700", :id => '55018883@N00', :range => 601..700 },
      { :name => "Views: 701-800", :id => '57949802@N00', :range => 701..800 },
      { :name => "Views: 801-900", :id => '11312712@N00', :range => 801..900 },
      { :name => "Views: 901-1000", :id => '25733561@N00', :range => 901..1000 },
      { :name => "Views: 1000-1250", :id => '52647536@N00', :range => 1001..1249 },
      { :name => "Views: 1250-1500", :id => '55588602@N00', :range => 1250..1499 },
      { :name => "Views: 1500-1750", :id => '69216155@N00', :range => 1500..1749 },
      { :name => "Views: 1750-2000", :id => '37622092@N00', :range => 1750..1999 },
      { :name => "Views: 2000-2500", :id => '59068415@N00', :range => 2000..2499 },
      { :name => "Views: 2500-3000", :id => '52631960@N00', :range => 2500..2999 },
      { :name => "Views: 3000-4000", :id => '39788208@N00', :range => 3000..3999 },
      { :name => "Views: 4000-5000", :id => '68161359@N00', :range => 4000..4999 },
      { :name => "Views: 5000-7500", :id => '413251@N22', :range => 5000..7499 },
      { :name => "Views: 7500-10000", :id => '413255@N22', :range => 7500..9999 },
      { :name => "Views: 10000-15000", :id => '390685@N23', :range => 10000..14999 },
      { :name => "Views: 15000-20000", :id => '349288@N24', :range => 15000..19999 },
      { :name => "Views: 20000+", :id => '349290@N24', :range => 20000..99999 },

      { :name => "10 views (-25)", :id => '33472647@N00', :range => 10..24 },
      { :name => "25 Views (-50)", :id => '43124025@N00', :range => 25..49 },
      { :name => "50 Views (-75)", :id => '93546797@N00', :range => 50..74 },
      { :name => "75 Views (-100)", :id => '20113502@N00', :range => 75..99 },

      { :name => "25 View Club", :id => '39214358@N00', :range => 25..49 },
      { :name => "50 View Club", :id => '16704534@N00', :range => 50..99 },
      { :name => "100 View Club", :id => '78732724@N00', :range => 100..199 },
      { :name => "200 View Club", :id => '35288132@N00', :range => 200..299 },
      { :name => "300 View Club", :id => '45273677@N00', :range => 300..399 },
      { :name => "400 View Club", :id => '87174132@N00', :range => 400..499 },
      { :name => "500 View Club", :id => '56517715@N00', :range => 500..599 },
      { :name => "600 View Club", :id => '38079087@N00', :range => 600..699 },
      { :name => "700 View Club", :id => '64182597@N00', :range => 700..799 },
      { :name => "800 View Club", :id => '95039446@N00', :range => 800..899 },
      { :name => "900 View Club", :id => '98113559@N00', :range => 900..999 },
      { :name => "1,000 View Club", :id => '30605672@N00', :range => 1000..1099 },
      { :name => "1,100 Plus View Club", :id => '62602380@N00', :range => 1100..99999 },

      { :name => "minimum 100 views", :id => '88744574@N00', :range => 100..249 },
      { :name => "minimum 250 views", :id => '53262654@N00', :range => 250..499 },
      { :name => "minimum 500 views", :id => '51308661@N00', :range => 500..699 },
      { :name => "minimum 700 views", :id => '71794126@N00', :range => 700..999 },
      { :name => "minimum 1000 views", :id => '21441943@N00', :range => 1000..1999 },
      { :name => "minimum 2000 views", :id => '78934823@N00', :range => 2000..2999 },
      { :name => "minimum 3000 views", :id => '79108944@N00', :range => 3000..3999 },
      { :name => "minimum 4000 views", :id => '78142473@N00', :range => 4000..4999 },

      { :name => "Views 100", :id => '64501366@N00', :range => 100..199 },
      { :name => "Views 200", :id => '40663022@N00', :range => 200..299 },
      { :name => "Views 300", :id => '17449184@N00', :range => 300..399 },
      { :name => "Views 400", :id => '42514748@N00', :range => 400..499 },
      { :name => "Views 500", :id => '29164599@N00', :range => 500..599 },
      { :name => "Views 600", :id => '89901924@N00', :range => 600..699 },
      { :name => "Views 700", :id => '10145901@N00', :range => 700..799 },
      { :name => "Views 800", :id => '94735186@N00', :range => 800..899 },
      { :name => "Views 900", :id => '42093148@N00', :range => 900..999 },
      { :name => "Views 1000", :id => '23848474@N00', :range => 1000..1499 },
      { :name => "Views 1500", :id => '50092931@N00', :range => 1500..1999 },
      { :name => "Views 2000", :id => '58759937@N00', :range => 2000..2499 },
      { :name => "Views 2500", :id => '68461256@N00', :range => 2500..2999 },
      { :name => "Views 3000", :id => '20933222@N00', :range => 3000..3499 },
      { :name => "Views 3500", :id => '66977805@N00', :range => 3500..3999 },
      { :name => "Views 4000", :id => '29786937@N00', :range => 4000..4499 },
      { :name => "Views 4500", :id => '15223505@N00', :range => 4500..4999 },
      { :name => "Views 5000", :id => '26856597@N00', :range => 5000..5999 },
      { :name => "Views 6000", :id => '21724132@N00', :range => 6000..6999 },
      { :name => "Views 7000", :id => '72031358@N00', :range => 7000..7999 },
      { :name => "Views 8000", :id => '42158309@N00', :range => 8000..8999 },
      { :name => "Views 9000", :id => '27906782@N00', :range => 9000..9999 },

      { :name => "600 Views", :id => '59171278@N00', :range => 600..699 },
      { :name => "700 Views", :id => '22931522@N00', :range => 700..799 },
      { :name => "800 views (-900)", :id => '15389017@N00', :range => 800..899 },
      { :name => "900 Views (-1000)", :id => '52663578@N00', :range => 900..999 },
      { :name => "1100 views (-1200)", :id => '48585996@N00', :range => 1100..1199 },
      { :name => "1200 Views (-1300)", :id => '23626801@N00', :range => 1200..1299 },

      { :name => "~Under 25~", :id => '15983640@N00', :range => 1..24 },
      { :name => "~25 to 50~", :id => '47846660@N00', :range => 25..49 },
      { :name => "~50 to 75~", :id => '95181683@N00', :range => 50..74 },
      { :name => "~75 to 100~", :id => '86604429@N00', :range => 75..99 },
      { :name => "~100 to 150~", :id => '65878370@N00', :range => 100..149 },
      { :name => "~150 to 200~", :id => '82648087@N00', :range => 150..199 },
      { :name => "~200 to 300~", :id => '32499602@N00', :range => 200..299 },
      { :name => "~300 to 400~", :id => '99788504@N00', :range => 300..399 },
      { :name => "~400 to 500~", :id => '10512556@N00', :range => 400..499 },
      { :name => "~500 to 600~", :id => '27112172@N00', :range => 500..599 },
      { :name => "~600 to 700~", :id => '32613242@N00', :range => 600..699 },
      { :name => "~700 to 800~", :id => '55043006@N00', :range => 700..799 },
      { :name => "~800 to 900~", :id => '62802662@N00', :range => 800..899 },
      { :name => "~900 to 1,000~", :id => '87655904@N00', :range => 900..999 },
      { :name => "~1,000 to 1,250~", :id => '84191108@N00', :range => 1000..1249 },
      { :name => "~1,250 to 1,500~", :id => '63751279@N00', :range => 1250..1500 },

      { :name => "Photos with 100 Views", :id => '28905528@N00', :range => 100..199 },
      { :name => "Photos with 200 (- 299) views", :id => '81383576@N00', :range => 200..299 },
      { :name => "Photos with 300 (- 399) views", :id => '32096434@N00', :range => 300..399 },
      { :name => "Photos with 400 (- 499) views", :id => '94544825@N00', :range => 400..499 },
      { :name => "Photos with 500 (- 599) views", :id => '51742214@N00', :range => 500..599 },
      { :name => "Photos with 600 (- 699) views", :id => '51952502@N00', :range => 600..699 },
      { :name => "Photos with 700 (- 799) views", :id => '11514012@N00', :range => 700..799 },
      { :name => "Photos with 800 (- 899) views", :id => '29157411@N00', :range => 800..899 },
      { :name => "Photos with 900 (- 999) views", :id => '27112996@N00', :range => 900..999 },
      { :name => "Photos with 1000 views (and more)", :id => '42827898@N00', :range => 1000..99999 },
    ]

    def initialize
      @db = Database.new
      @flickr = Flickr.new
      @log = Log.new 'sf'

      token, secret = @db.get_token SERVICE_NAME
      if token
        @flickr.set_auth token, secret
      else
        token, secret = @flickr.do_auth
        @db.add_token SERVICE_NAME, token, secret
      end
    end

    def checkPhoto count, photo
      puts "#{count}. Checking photo #{photo.id} \"#{photo.title}\"..."
      @log.puts "#{count}. Checking photo <a href=\"http://www.flickr.com/#{photo.owner}/#{photo.id}\">#{photo.id} \"#{photo.title}\"</a>..."

      views = photo.views.to_i

      puts "#{views} views"
      @log.puts "#{views} views"

      results = Flickr::flickr_retry {
        flickr.photos.getAllContexts :photo_id => photo.id
      }

      # Get a list of IDs of pools to which this photo belongs.
      pools = {}
      # results['pool'] may be nil if the photo doesn't belong to any
      # group. Coerce it to an array to guard against that.
      results['pool'].to_a.each { |pool|
        pools[pool.id] = true
      }

      GROUPS.each { |group|
        if pools[group[:id]] and !group[:range].cover?(views)
          removePhotoFromGroup photo, group
        end
        if !pools[group[:id]] and group[:range].cover?(views)
          addPhotoToGroup photo, group
        end
      }
    end

    def getPhotos pagenum, pagelen
      Flickr::flickr_retry {
        flickr.people.getPhotos :user_id => 'me', :per_page => pagelen, :page => pagenum, :extras => 'views' 
      }
    end

    def addPhotoToGroup photo, group
      return if group[:hitlimit]

      puts "Adding photo #{photo.id} to group #{group[:name]}..."
      @log.puts "Adding photo #{photo.id} to group #{group[:name]}..."

      begin
        Flickr::flickr_retry {
          flickr.groups.pools.add :photo_id => photo.id, :group_id => group[:id]
        }
      rescue FlickRaw::FailedResponse => err
        warn "#{err.code}: #{err.msg}"
        @log.puts "#{err.code}: #{err.msg}"
        # Error code 5 is 'photo limit reached'. Make a note of that, so we
        # don't try to add any more photos to this group.
        if err.code == 5
          group[:hitlimit] = true
        end
      end
    end

    def removePhotoFromGroup photo, group
      puts "Removing photo #{photo.id} from group #{group[:name]}..."
      @log.puts "Removing photo #{photo.id} from group #{group[:name]}..."

      begin
        Flickr::flickr_retry {
          flickr.groups.pools.remove :photo_id => photo.id, :group_id => group[:id]
        }
      rescue FlickRaw::FailedResponse => err
        warn "#{err.code}: #{err.msg}"
        @log.puts "#{err.code}: #{err.msg}"
      end
    end

    def randomProbe
      totalpics = (getPhotos 1, 1).total.to_i
      puts "Total = #{totalpics}"
      @log.puts "Total = #{totalpics}"

      checked = {}
      count = 0

      loop do
        picnum = 1 + rand(totalpics)

        result = (getPhotos picnum, 1).first
        id = result.id
        if checked[id]
          puts "Photo #{id} already checked. Skipping."
          @log.puts "Photo #{id} already checked. Skipping."
        else
          count += 1
          checkPhoto count, result
          checked[id] = true
        end

        sleep 1
      end
    end
  end
end

begin
  selfpool = PoolRB::SelfPool.new
  selfpool.randomProbe
rescue Interrupt
  warn "Interrupted! Exiting..."
end

# -- END --

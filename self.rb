require 'rubygems'
require 'flickr'
require 'database'

module PoolRB

  class SelfPool

    SERVICE_NAME = 'self'

    GROUPS = [
      { :name => "1-25 Views", :id => '66969363@N00', :lbound => 1, :ubound => 24 },
      { :name => "25-50 Views", :id => '55265535@N00', :lbound => 25, :ubound => 49 },
      { :name => "50-75 Views", :id => '38541060@N00', :lbound => 50, :ubound => 74 },
      { :name => "75-100 Views", :id => '45499242@N00', :lbound => 75, :ubound => 99 },
      { :name => "100-150 Views", :id => '25694047@N00', :lbound => 100, :ubound => 149 },
      { :name => "150-200 Views", :id => '57008537@N00', :lbound => 150, :ubound => 199 },

      { :name => "Views: 25", :id => '14813384@N00', :lbound => 25, :ubound => 49 },
      { :name => "Views: 50", :id => '63923506@N00', :lbound => 50, :ubound => 74 },
      { :name => "Views: 75", :id => '26651003@N00', :lbound => 75, :ubound => 99 },
      { :name => "Views: 100", :id => '37045109@N00', :lbound => 100, :ubound => 199 },
      { :name => "Views: 200", :id => '35419517@N00', :lbound => 200, :ubound => 299 },
      { :name => "Views: 300", :id => '76852794@N00', :lbound => 300, :ubound => 399 },
      { :name => "Views: 400", :id => '97866666@N00', :lbound => 400, :ubound => 499 },
      { :name => "Views: 500", :id => '32266655@N00', :lbound => 500, :ubound => 599 },
      { :name => "Views: 600", :id => '50687206@N00', :lbound => 600, :ubound => 699 },
      { :name => "Views: 700", :id => '65104419@N00', :lbound => 700, :ubound => 799 },
      { :name => "Views: 800", :id => '87608476@N00', :lbound => 800, :ubound => 899 },
      { :name => "Views: 900", :id => '79303709@N00', :lbound => 900, :ubound => 999 },
      { :name => "Views: 1000", :id => '85342170@N00', :lbound => 1000, :ubound => 1249 },
      { :name => "Views: 1250", :id => '66448677@N00', :lbound => 1250, :ubound => 1499 },
      { :name => "Views: 1500", :id => '18374590@N00', :lbound => 1500, :ubound => 1749 },
      { :name => "Views: 1750", :id => '25661400@N00', :lbound => 1750, :ubound => 1999 },
      { :name => "Views: 2000", :id => '44588749@N00', :lbound => 2000, :ubound => 2999 },
      { :name => "Views: 3000", :id => '10386539@N00', :lbound => 3000, :ubound => 3999 },
      { :name => "Views: 4000", :id => '69218008@N00', :lbound => 4000, :ubound => 4999 },
      { :name => "Views: 5000", :id => '52498228@N00', :lbound => 5000, :ubound => 9999 },
      { :name => "Views: 10000", :id => '28114976@N00', :lbound => 10000, :ubound => 24999 },
      { :name => "Views: 25000", :id => '665334@N25', :lbound => 25000, :ubound => 999999 },

      { :name => " 100+ Views OR 10+ Favorites", :id => '53758961@N00', :lbound => 100, :ubound => 99999 },
      { :name => "50 Views - 100", :id => '33128095@N00', :lbound => 50, :ubound => 99 },
      { :name => "50 to 99 views", :id => '47017726@N00', :lbound => 50, :ubound => 99 },
      { :name => "Centurian Club", :id => '38475367@N00', :lbound => 100, :ubound => 199 },
      { :name => "200 Views", :id => '12476408@N00', :lbound => 200, :ubound => 299 },    
      { :name => "200 Views (freeminded)", :id => '23348528@N00', :lbound => 200, :ubound => 299 },
      { :name => "100 Views", :id => '49688781@N00', :lbound => 100, :ubound => 199 },
      { :name => "100 Views - 200", :id => '49864370@N00', :lbound => 100, :ubound => 199 },
      { :name => "300 Views - 499", :id => '94294471@N00', :lbound => 300, :ubound => 499 },
      { :name => "400 Views", :id => '73162739@N00', :lbound => 400, :ubound => 499 },
      { :name => "500 Views", :id => '29315372@N00', :lbound => 500, :ubound => 599 },
      { :name => "600 Views", :id => '93769266@N00', :lbound => 600, :ubound => 999 },
      { :name => "1000 Views", :id => '83435940@N00', :lbound => 1000, :ubound => 1499 },

      { :name => "Views: 7-25", :id => '54402757@N00', :lbound => 7, :ubound => 25 },
      { :name => "Views: 26-50", :id => '54083170@N00', :lbound => 26, :ubound => 50 },
      { :name => "Views: 51-75", :id => '25553907@N00', :lbound => 51, :ubound => 75 },
      { :name => "Views: 76-100", :id => '76213832@N00', :lbound => 76, :ubound => 100 },
      { :name => "Views: 101-200", :id => '37847006@N00', :lbound => 101, :ubound => 200 },
      { :name => "Views: 201-300", :id => '23297148@N00', :lbound => 201, :ubound => 300 },
      { :name => "Views: 301-400", :id => '51348184@N00', :lbound => 301, :ubound => 400 },
      { :name => "Views: 401-500", :id => '36708499@N00', :lbound => 401, :ubound => 500 },
      { :name => "Views: 501-600", :id => '82555169@N00', :lbound => 501, :ubound => 600 },
      { :name => "Views: 601-700", :id => '55018883@N00', :lbound => 601, :ubound => 700 },
      { :name => "Views: 701-800", :id => '57949802@N00', :lbound => 701, :ubound => 800 },
      { :name => "Views: 801-900", :id => '11312712@N00', :lbound => 801, :ubound => 900 },
      { :name => "Views: 901-1000", :id => '25733561@N00', :lbound => 901, :ubound => 1000 },
      { :name => "Views: 1000-1250", :id => '52647536@N00', :lbound => 1001, :ubound => 1249 },
      { :name => "Views: 1250-1500", :id => '55588602@N00', :lbound => 1250, :ubound => 1500 },

      { :name => "10 views (-25)", :id => '33472647@N00', :lbound => 10, :ubound => 24 },
      { :name => "25 Views (-50)", :id => '43124025@N00', :lbound => 25, :ubound => 49 },
      { :name => "50 Views (-75)", :id => '93546797@N00', :lbound => 50, :ubound => 74 },
      { :name => "75 Views (-100)", :id => '20113502@N00', :lbound => 75, :ubound => 99 },

      { :name => "25 View Club", :id => '39214358@N00', :lbound => 25, :ubound => 49 },
      { :name => "50 View Club", :id => '16704534@N00', :lbound => 50, :ubound => 99 },
      { :name => "100 View Club", :id => '78732724@N00', :lbound => 100, :ubound => 199 },
      { :name => "200 View Club", :id => '35288132@N00', :lbound => 200, :ubound => 299 },
      { :name => "300 View Club", :id => '45273677@N00', :lbound => 300, :ubound => 399 },
      { :name => "400 View Club", :id => '87174132@N00', :lbound => 400, :ubound => 499 },
      { :name => "500 View Club", :id => '56517715@N00', :lbound => 500, :ubound => 599 },
      { :name => "600 View Club", :id => '38079087@N00', :lbound => 600, :ubound => 699 },
      { :name => "700 View Club", :id => '64182597@N00', :lbound => 700, :ubound => 799 },
      { :name => "800 View Club", :id => '95039446@N00', :lbound => 800, :ubound => 899 },
      { :name => "900 View Club", :id => '98113559@N00', :lbound => 900, :ubound => 999 },
      { :name => "1,000 View Club", :id => '30605672@N00', :lbound => 1000, :ubound => 1099 },
      { :name => "1,100 Plus View Club", :id => '62602380@N00', :lbound => 1100, :ubound => 99999 },

      { :name => "minimum 100 views", :id => '88744574@N00', :lbound => 100, :ubound => 249 },
      { :name => "minimum 250 views", :id => '53262654@N00', :lbound => 250, :ubound => 499 },
      { :name => "minimum 500 views", :id => '51308661@N00', :lbound => 500, :ubound => 699 },
      { :name => "minimum 700 views", :id => '71794126@N00', :lbound => 700, :ubound => 999 },
      { :name => "minimum 1000 views", :id => '21441943@N00', :lbound => 1000, :ubound => 1999 },

      { :name => "Views 100", :id => '64501366@N00', :lbound => 100, :ubound => 199 },
      { :name => "Views 200", :id => '40663022@N00', :lbound => 200, :ubound => 299 },
      { :name => "Views 300", :id => '17449184@N00', :lbound => 300, :ubound => 399 },
      { :name => "Views 400", :id => '42514748@N00', :lbound => 400, :ubound => 499 },
      { :name => "Views 500", :id => '29164599@N00', :lbound => 500, :ubound => 599 },
      { :name => "Views 600", :id => '89901924@N00', :lbound => 600, :ubound => 699 },
      { :name => "Views 700", :id => '10145901@N00', :lbound => 700, :ubound => 799 },
      { :name => "Views 800", :id => '94735186@N00', :lbound => 800, :ubound => 899 },
      { :name => "Views 900", :id => '42093148@N00', :lbound => 900, :ubound => 999 },
      { :name => "Views 1000", :id => '23848474@N00', :lbound => 1000, :ubound => 1499 },

      { :name => "600 Views", :id => '59171278@N00', :lbound => 600, :ubound => 699 },
      { :name => "700 Views", :id => '22931522@N00', :lbound => 700, :ubound => 799 },
      { :name => "800 views (-900)", :id => '15389017@N00', :lbound => 800, :ubound => 899 },
      { :name => "900 Views (-1000)", :id => '52663578@N00', :lbound => 900, :ubound => 999 },
      { :name => "1100 views (-1200)", :id => '48585996@N00', :lbound => 1100, :ubound => 1199 },
      { :name => "1200 Views (-1300)", :id => '23626801@N00', :lbound => 1200, :ubound => 1299 },

      { :name => "~Under 25~", :id => '15983640@N00', :lbound => 1, :ubound => 24 },
      { :name => "~25 to 50~", :id => '47846660@N00', :lbound => 25, :ubound => 49 },
      { :name => "~50 to 75~", :id => '95181683@N00', :lbound => 50, :ubound => 74 },
      { :name => "~75 to 100~", :id => '86604429@N00', :lbound => 75, :ubound => 99 },
      { :name => "~100 to 150~", :id => '65878370@N00', :lbound => 100, :ubound => 149 },
      { :name => "~150 to 200~", :id => '82648087@N00', :lbound => 150, :ubound => 199 },
      { :name => "~200 to 300~", :id => '32499602@N00', :lbound => 200, :ubound => 299 },
      { :name => "~300 to 400~", :id => '99788504@N00', :lbound => 300, :ubound => 399 },
      { :name => "~400 to 500~", :id => '10512556@N00', :lbound => 400, :ubound => 499 },
      { :name => "~500 to 600~", :id => '27112172@N00', :lbound => 500, :ubound => 599 },
      { :name => "~600 to 700~", :id => '32613242@N00', :lbound => 600, :ubound => 699 },
      { :name => "~700 to 800~", :id => '55043006@N00', :lbound => 700, :ubound => 799 },
      { :name => "~800 to 900~", :id => '62802662@N00', :lbound => 800, :ubound => 899 },
      { :name => "~900 to 1,000~", :id => '87655904@N00', :lbound => 900, :ubound => 999 },
      { :name => "~1,000 to 1,250~", :id => '84191108@N00', :lbound => 1000, :ubound => 1249 },
      { :name => "~1,250 to 1,500~", :id => '63751279@N00', :lbound => 1250, :ubound => 1500 },

      { :name => "Photos with 100 Views", :id => '28905528@N00', :lbound => 100, :ubound => 199 },
      { :name => "Photos with 200 (- 299) views", :id => '81383576@N00', :lbound => 200, :ubound => 299 },
      { :name => "Photos with 300 (- 399) views", :id => '32096434@N00', :lbound => 300, :ubound => 399 },
      { :name => "Photos with 400 (- 499) views", :id => '94544825@N00', :lbound => 400, :ubound => 499 },
      { :name => "Photos with 500 (- 599) views", :id => '51742214@N00', :lbound => 500, :ubound => 599 },
      { :name => "Photos with 600 (- 699) views", :id => '51952502@N00', :lbound => 600, :ubound => 699 },
      { :name => "Photos with 700 (- 799) views", :id => '11514012@N00', :lbound => 700, :ubound => 799 },
      { :name => "Photos with 800 (- 899) views", :id => '29157411@N00', :lbound => 800, :ubound => 899 },
      { :name => "Photos with 900 (- 999) views", :id => '27112996@N00', :lbound => 900, :ubound => 999 },
      { :name => "Photos with 1000 views (and more)", :id => '42827898@N00', :lbound => 1000, :ubound => 99999 },
    ]

    def initialize
      @db = Database.new
      @flickr = Flickr.new

      token, secret = @db.get_token SERVICE_NAME
      if token
        @flickr.set_auth token, secret
      else
        token, secret = @flickr.do_auth
        @db.add_token SERVICE_NAME, token, secret
      end
    end

    def getPhotos pagenum, pagelen
      Flickr::flickr_retry { flickr.people.getPhotos :user_id => 'me', :per_page => pagelen, :page => pagenum, :extras => 'views' }
    end

  end
end

selfpool = PoolRB::SelfPool.new
result = selfpool.getPhotos 1, 10
puts "Total photos: #{result.total}"
result.each { |photo|
  puts "Photo #{photo.id} \"#{photo.title}\": #{photo.views} views"
}

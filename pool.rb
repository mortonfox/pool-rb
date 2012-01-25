require 'rubygems'
require 'flickr'
require 'database'
require 'log'

module PoolRB

  class CleanPool

    GROUPS = {
      25 => { :name => "1-25 Views", :id => '66969363@N00', :range => 0..25 },
      50 => { :name => "25-50 Views", :id => '55265535@N00', :range => 25..50 },
      75 => { :name => "50-75 Views", :id => '38541060@N00', :range => 50..75 },
      100 => { :name => "75-100 Views", :id => '45499242@N00', :range => 75..100 },
      200 => { :name => "150-200 Views", :id => '57008537@N00', :range => 150..200 },
    }

  end

end

if __FILE__ == $0
end

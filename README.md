# pool-rb - Management scripts for Flickr views groups

Views groups are Flickr groups that allow you to add only photos with a certain
number of views. For example, a "Views 25-50" group accepts only photos with a
view count of 25 to 50. Since Flickr does not yet have a feature to enforce
view count restrictions, moderation of views groups is done either by hand or
by Flickr API scripts such as this one.

## pool.rb

This script moderates one or more Flickr views groups, removing any photos it
finds that violate the group views restriction. Group info is hardcoded in
`PoolRB::CleanPool::GROUPS` in the script. The script operates in two modes:

* `pool.rb -f` (or simply `pool.rb`)

    Clean up all the groups, starting from the first page (one page = 100
    photos) until it reaches the last page or is interrupted.

* `pool.rb -r`

    Clean up pages chosen at random from the groups until you stop the script.

In the latter mode, random probing ensures that the script will cover all the
groups evenly if you run it long enough. In practice, running it for 5 to 10
minutes a day is enough to keep groups relatively clean.

## self.rb

This script manages your photos in one or more Flickr views groups,
adding/removing them from groups depending on view counts. Group info is
hardcoded in `PoolRB::SelfPool::GROUPS` in the script.

This script only does random probing, checking random photos from your
photostream until you stop the script. This is the same idea as the random
probing in pool.rb, but applied within your photostream. In practice, it is
sufficient to let self.rb random-probe about 100 photos per day.

<!-- vim:set tw=0: -->

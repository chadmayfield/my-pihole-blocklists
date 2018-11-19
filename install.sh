#!/bin/bash

# install_blocklists.sh - install generated blocklists

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

# NOTE: 

# check if we're actually on a pihole (and a new version at that)
command -v pi-hole >/dev/null 2>&1 || { \
    echo >&2 "ERROR: You must run this on a pi-hole!"; exit 1; }

# no reason to su to root, pihole takes care of that
#if [ $UID -ne 0 ]; then
#    echo "ERROR: You must be root to isntall this!"
#    exit 1
#fi

# check if users is in sudoers file?


# install blocklists
repo="https://github.com/chadmayfield/pihole-blocklists.git"
location="/tmp/pihole-blocklist-$$"
git clone $repo $location

# change to cloned dir and create our current blocklists
(
cd $location || return
perl create_blocklist_porn.pl
)

# add blocklist url to 
#light_list="https://github.com/chadmayfield/pihole-blocklists/blob/master/lists/pi_blocklist_porn_top1m.list"
#heavy_list="https://github.com/chadmayfield/pihole-blocklists/blob/master/lists/pi_blocklist_porn_all.list"

# enable other repos
cp /etc/pihole/adlists.default /etc/pihole/adlists.list

# add blacklisted domains (not in a list
blacklist=( "ad.pandora.tv" 
            "ads.pandora.tv.net" 
            "stats.pandora.com" 
            "adserver.pandora.com" 
            "r{1..20}---sn-8xgp1vo-xfgd.googlevideo.com" 
            "r{1..20}---sn-8xgp1vo-xfgee.googlevideo.com" 
            "r{1..20}---sn-p5qs7n7s.googlevideo.com" )

for i in "${blacklist[@]}"
do
    echo "blacklisting: $i"
done


# add whitelisted domains
whitelist=( "clients4.google.com" 
            "clients3.google.com" 
            "s.youtube.com"
            "video-stats.l.google.com"
            "spclient.wg.spotify.com"
            "www.msftncsi.com" 
            "outlook.office365.com" 
            "products.office.com" 
            "c.s-microsoft.com" 
            "i.s-microsoft.com" 
            "login.live.com"
            "g.live.com"
            "dl.delivery.mp.microsoft.com" 
            "geo-prod.do.dsp.mp.microsoft.com" 
            "displaycatalog.mp.microsoft.com" 
            "officeclient.microsoft.com"
            "s.gateway.messenger.live.com" 
            "ui.skype.com" 
            "pricelist.skype.com" 
            "apps.skype.com" 
            "m.hotmail.com" 
            "s.gateway.messenger.live.com" 
            "sa.symcb.com" 
            "s{1..5}.symcb.com"
            "plex.tv" 
            "tvdb2.plex.tv" 
            "pubsub.plex.bz" 
            "proxy.plex.bz" 
            "proxy02.pop.ord.plex.bz" 
            "cpms.spop10.ams.plex.bz" 
            "meta-db-worker02.pop.ric.plex.bz" 
            "meta.plex.bz" 
            "tvthemes.plexapp.com.cdn.cloudflare.net" 
            "tvthemes.plexapp.com" 
            "106c06cd218b007d-b1e8a1331f68446599e96a4b46a050f5.ams.plex.services" 
            "meta.plex.tv" 
            "cpms35.spop10.ams.plex.bz" 
            "proxy.plex.tv" 
            "metrics.plex.tv" 
            "pubsub.plex.tv" 
            "status.plex.tv" 
            "www.plex.tv" 
            "node.plexapp.com" 
            "nine.plugins.plexapp.com" 
            "staging.plex.tv" 
            "app.plex.tv" 
            "o1.email.plex.tv" 
            "o2.sg0.plex.tv" 
            "dashboard.plex.tv"
            "gravatar.com" 
            "thetvdb.com" 
            "themoviedb.com" 
            "services.sonarr.tv" 
            "skyhook.sonarr.tv" 
            "download.sonarr.tv" 
            "apt.sonarr.tv" 
            "forums.sonarr.tv" )

# rather than passing the array to pihole, loop and run each domain one-by-one
for i in "${whitelist[@]}"
do
    echo "whitelisting: $i"
    pihole -w "$i"
done

# update the pi-hole if it's a new enough version
echo "checking for pi-hole update..."
pi-hole -up

#EOF

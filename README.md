# my-pihole-blocklists

Create custom [pi-hole](https://pi-hole.net/) [blocklists](https://github.com/pi-hole/pi-hole/wiki/Customising-sources-for-ad-lists#block-more-than-advertisements) to block unwanted traffic to a network.

### Disclaimer
*This project is in **no way** affiliated with the core Pi-Hole project or organization. This project was created as a contribution to the community by providing high quality blocklists. Use at your own risk.*

## Screenshots
Pi-hole dashboard with the default, light, and heavy porn blocklists installed;

| Running with default ruleset | Top 1m (Light List) | All (Heavy List) |
| :--------------------------: | :------------------:| :---------------:|
| ![default blocklist](http://i.imgur.com/Nq9vCM7.png) | ![light blocklist](http://i.imgur.com/vA3YWjp.png) | ![heavy blocklist](http://i.imgur.com/7e8xpUl.png) |

And the affect of having the porn list installed;

![Site Blocked!](http://i.imgur.com/uzBFPxI.png)

## Supported lists

Currently supported lists;
1. porn (via `create_blocklist_porn.pl` which creates two lists)<br />
... **light list**: `pi_blocklist_porn_top1m.list` (~21k domains). This list is a correlated list to only block porn sites that appear on Alex'a top 1m site list.<br />
... **heavy list**: `pi_blocklist_porn_all.list` (~2m domains). This list is a slightly edited list from Université Toulouse 1 Capitole.  _NOTE: Use caution when using this list with embedded computers._<br />
2. more coming soon...

## Requirements
* Perl
* Array::Utils (install via `sudo perl -MCPAN -e 'install Array::Utils'`)

## Installation
1. SSH to deployed pi-hole
2. Copy adlists.default to adlists.list `sudo cp /etc/pihole/adlists.default /etc/pihole/adlists.list`
3. Edit `sudo vi /etc/pihole/adlists.list` to add one of the following lists;<br />
... **Light**: `https://raw.githubusercontent.com/chadmayfield/pihole-blocklists/master/lists/pi_blocklist_porn_top1m.list`<br />
... **Heavy** `https://raw.githubusercontent.com/chadmayfield/pihole-blocklists/master/lists/pi_blocklist_porn_all.list`<br />
4. Run `pihole -g` to update all lists
```
pi¾pi-hole:´ $ pihole -g
:::
::: Neutrino emissions detected...
:::
::: Pulling source lists into range... done!
:::
::: Getting raw.githubusercontent.com list... done
:::   Status: Success (OK)
:::   List updated, transport successful!
::: Getting mirror1.malwaredomains.com list... done
:::   Status: Not modified
:::   No changes detected, transport skipped!
::: Getting sysctl.org list... done
:::   Status: Not modified
:::   No changes detected, transport skipped!
::: Getting zeustracker.abuse.ch list... done
:::   Status: Not modified
:::   No changes detected, transport skipped!
::: Getting s3.amazonaws.com list... done
:::   Status: Not modified
:::   No changes detected, transport skipped!
::: Getting s3.amazonaws.com list... done
:::   Status: Not modified
:::   No changes detected, transport skipped!
::: Getting hosts-file.net list... done
:::   Status: Not modified
:::   No changes detected, transport skipped!
::: 
::: Aggregating list of domains... done!
::: Formatting list of domains to remove comments.... done!
::: 128651 domains being pulled in by gravity...
::: Removing duplicate domains.... done!
::: 105011 unique domains trapped in the event horizon.
:::
::: Adding adlist sources to the whitelist... done!
::: Whitelisting 9 domains... done!
::: Nothing to blacklist!
::: No wildcards used!
::: Formatting domains into a HOSTS file... done!
:::
::: Cleaning up un-needed files... done!
:::
::: Refresh lists in dnsmasq... done!
::: DNS service is running
::: Pi-hole blocking is Enabled
```

## Sample blocklist creation ouput 

```
[chad@myhost:~] $ ./create_blocklist_porn.pl 
beginning downloads
download complete: top-1m.csv.zip
download complete: adult.tar.gz
extracting files
extracting file: top-1m.csv.zip
  loading alexa top-1m domains
  loaded successfully
extracting file: adult.tar.gz
  loading domains from adult.tar.gz
  loaded successfully
comparing lists for commonality
counting lines...done
*******************************************************************
Light blocklist created: pi_blocklist_porn_top1m.list (21492 lines)
Heavy blocklist created: pi_blocklist_porn_all.list (1980211 lines)
*******************************************************************
```

**NOTE**: This is a work in progress and is being actively developed (for now).

## TODO
- [ ] Cleanup the code! (most of this was written as PoC)
- [ ] Log output from script to file rather than STDOUT
- [X] Add comparison to Alexa top 1 million sites to only block the top sites
- [ ] Add cron script to run from cron daily/weekly/monthly
- [ ] Add installation script for automated install
- [ ] Add additional lists to combine into one mega list
- [ ] Possibly generizie script to accept any list
- [ ] Add instructions to host the list on the pi-host itself
- [ ] Add the Cisco Umbrella OpenDNS Top 1 Million list
- [ ] Add the Majestic Million list
- [ ] Add the Stavoo Top 1 Million list

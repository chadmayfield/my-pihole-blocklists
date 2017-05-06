# pihole-blocklists

Create custom [pi-hole](https://pi-hole.net/) [blocklists](https://github.com/pi-hole/pi-hole/wiki/Customising-sources-for-ad-lists#block-more-than-advertisements). To block unwanted traffic to a network.

Currently supported lists;
* porn (via `create_blocklist_porn.pl` which creates two lists)
..* light list: `pi_blocklist_porn_top1m.list` (~21k domains). This list is a correlated list to only block porn sites that appear on Alex'a top 1m site list.
..* heavy list: `pi_blocklist_porn_all.list` (~2m domains). This list is a slightly edited list from Université Toulouse 1 Capitole.  _NOTE: Use caution when using this list with embedded computers._
* more coming soon...

**DISCLAIMER**: This is a work in progress, and is being actively developed.

## Requirements
* Perl
* Array::Utils (install via `sudo perl -MCPAN -e 'install Array::Utils'`)

## Installation
Coming soon!

## Sample ouput 

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

## TODO
- [ ] Cleanup the code! (most of this was written as PoC)
- [ ] Log output from script to file rather than STDOUT
- [X] Add comparison to Alexa top 1 million sites to only block the top sites
- [ ] Add cron script to run from cron daily/weekly/monthly
- [ ] Add installation script for automated install
- [ ] Add additional lists to combine into one mega list
- [ ] Possibly generizie script to accept any list

# pihole-blocklists

Create custom [pi-hole](https://pi-hole.net/) [blocklists](https://github.com/pi-hole/pi-hole/wiki/Customising-sources-for-ad-lists#block-more-than-advertisements). To block unwanted traffic to a network.

Currently supported lists;
* porn (via `create_blocklist_porn.pl`)
* more coming soon...

**DISCLAIMER**: This is a work in progress, and is being actively developed.

## Installation
Coming soon!

## Sample ouput 

```
[chad@myhost:~] $ ./create_blocklist_porn.pl 
Starting download of adult.tar.gz...done.
Extracting adult.tar.gz...done.
Removing bad lines from 'adult/domains'...done.
*****************************************
Blocklist created: pi_blocklist_porn.list
*****************************************
```
```
[chad@myhost:~] $ ./create_blocklist_porn.pl 
The file adult.tar.gz exists, deleting it before download...done.
Starting download of adult.tar.gz...done.
Extracting adult.tar.gz...done.
Found existing pi_blocklist_porn.list, deleting it before proceeding...deleted.
Removing bad lines from 'adult/domains'...done.
*****************************************
Blocklist created: pi_blocklist_porn.list
*****************************************
```

## TODO
- [ ] Log output from script to file rather than STDOUT
- [ ] Add cron script to run from cron daily/weekly/monthly
- [ ] Add installation script for automated install
- [ ] Add additional lists to combine into one mega list
- [ ] Possibly generizie script to accept any list

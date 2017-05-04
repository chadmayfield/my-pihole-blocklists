#!/usr/bin/perl

# create_blocklist_porn.pl - create a pi-hole porn blocklist using public src

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

use strict;
use warnings;

use Archive::Tar;
use File::Fetch;
use File::Slurp;

# download list from Université Toulouse 1 Capitole, there isn't an update date
# on this site (http://dsi.ut-capitole.fr/blacklists/index_en.php) so we hope 
# that it's recent, if not we can always add more in the future
my $url = 'ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/adult.tar.gz';

# grab the filename
my $filename = substr $url, rindex($url, '/') + 1; 

if (-e $filename) {
    print "The file $filename exists, deleting it before download...";
    unlink $filename or die "ERROR: Unable to delete $filename!\n";
    print "done.\n";
}

# download
print "Starting download of $filename...";
my $ff = File::Fetch->new(uri => $url);
my $file = $ff->fetch() or die $ff->error;
print "done.\n";

# extract tarball that was downloaded
print "Extracting $filename...";

my $tar = Archive::Tar->new;
$tar->read($filename);
$tar->extract() or die "ERROR: Unable to extract $filename!\n";

print "done.\n";

# create our own custom block list by pruning IP's & bad lines
my $outfile = 'pi_blocklist_porn.list';

if (-e $outfile) {
    print "Found existing $outfile, deleting it before proceeding...";
    unlink $outfile or die "ERROR: Unable to delete $outfile!\n";
    print "deleted.\n"
}

open my $output, '>', $outfile or die "ERROR: Unable to write $outfile ($!)";

# read the domains list
my @array = read_file('adult/domains');

print "Removing bad lines from 'adult/domains'...";

# remove non-domains and any IP addresses
my $regexp = '^(xxx|porn|adult|sex|\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$';

for (@array){
    next if ($_ =~ /$regexp/);     
        print $output $_;
}
print "done.\n";

# TODO: add additional domains to blocklist

print "*****************************************\n";
print "Blocklist created: $outfile\n";
print "*****************************************\n";

# cleanup files
unlink($filename);
unlink(glob('adult/*'));
    rmdir 'adult';

#EOF

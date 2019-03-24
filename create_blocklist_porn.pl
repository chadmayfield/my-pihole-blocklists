#!/usr/bin/perl

# create_blocklist_porn.pl - create a pi-hole porn blocklist using public src

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

use strict;
use warnings;

use Archive::Tar;
use Archive::Zip;
use Array::Utils qw(:all);
use File::Copy;
use File::Fetch;
use File::Slurp;
use LWP::Simple;
use POSIX qw(strftime);

# get todays date
#my $today = `date +%Y%m%d`;
my $today = strftime "%Y%m%d", localtime;
my $archive_dir = "lists/archives/upstream/$today";

# we'll save the lists in these two files
my $top1m_list = "lists/pi_blocklist_porn_top1m.list";
my $all_list = "lists/pi_blocklist_porn_all.list";

# whitelist valid domains that may make it though from upstream
my $whitelistfile = "white.list";

my $url1 = "http://s3.amazonaws.com/alexa-static/top-1m.csv.zip";
my $url2 = "ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/adult.tar.gz";

my @files;
my @matches;
my @valid;

print "beginning downloads\n";

# download each url
foreach ($url1, $url2) {
    my $url = $_;

    # get filename
    my $ff = File::Fetch->new(uri => $url);
    my $filename = $ff->file;

    # add filename to array for later
    push @files, $filename;

    my $response = getstore($url, $filename);
        die "ERROR: Couldn't download $filename!" unless defined $response;

    print "download complete: $filename\n";
}

# create dir for archive files
unless ( -d "$archive_dir" ) {
    mkdir "$archive_dir",0755 or die $!;
}

print "extracting files\n";

# extract each file
foreach (@files) {
    my $filename = $_;
    my $suffix = ( split /\./, $filename )[-1];

    # copy archive file to archive directory
    copy("$filename","$archive_dir");

    print "extracting file: $filename\n";

    if ( $suffix =~ "gz" ) {
        my $tar = Archive::Tar->new;
        $tar->read($filename);
        $tar->extract() or die "ERROR: Unable to extract $filename!\n";

        # we can assume the file was adult.tar.gz for now
        if (-e "adult/domains") {
            print "  loading domains from $filename\n";

            # read the file into an array
            my @adult = read_file('adult/domains');

            # remove whitelisted domains
            my @whitelist = read_file($whitelistfile);
            my @compare = array_minus(@adult, @whitelist);

            # get rid of any IP's or non-domain words
            my $regexp = '^(xxx|porn|adult|sex|\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$';

            open LIST, ">", $all_list or die $!;

            # write all unmatched lines into tmpfile & load it into array
            for (@compare){
                my $tmpline = $_;
                next if ($_ =~ /$regexp/);
                # write to file
                print LIST $tmpline;
                # load into array as well
                push @valid, $_;
            }

            close LIST;

            print "  loaded successfully\n";
            
            # cleanup
            unlink $filename;
            unlink(glob('adult/*'));
            rmdir 'adult';
        }
    } elsif ( $suffix =~ "zip" ) {
        my $zip = Archive::Zip->new();
        my $zipname = $filename;
        my $status = $zip->read($zipname);
        die "ERROR: Can't read $zipname!\n" if $status != 0;

        # extract
        $zip->extractTree();

        # we can assume the alexa data we get is called top-1m.csv
        if (-e "top-1m.csv") {
            print "  loading alexa top-1m domains\n";
            $filename = "top-1m.csv";
        
            open my $fh1, '<', $filename or die "Cannot open $filename: $!";

            # load all domains into array
            while ( my $line = <$fh1> ) {
                my @ln = split ',', $line;
                push @matches, "$ln[1]";
            }

            close($fh1);

            print "  loaded successfully\n";

            # cleanup (trim extension to glob unlink)
            $filename = substr $filename, 0, rindex( $filename, q{.} );
            unlink(glob("$filename*"));
        }
    } else {
        die "ERROR: Unknown filetype!\n";
    }
}

print "comparing lists for commonality\n";

# get array intersections
my @isect = intersect(@valid, @matches);

open OUTFILE, ">", $top1m_list or die $!;
print OUTFILE @isect;

# TODO: fix this temp hack to add subdomains, it's fugly!
for my $i (@isect) {
    print OUTFILE "www.${i}";
}

close OUTFILE;

print "counting lines...";
# get the line count for each line
my $all_count;
open(ALLFILE, "< $all_list") or die "can't open $all_list: $!";
$all_count++ while <ALLFILE>;
close ALLFILE;

# get the line count for each line
my $top1m_count;
open(TOP1MFILE, "< $top1m_list") or die "can't open $top1m_list: $!";
$top1m_count++ while <TOP1MFILE>;
close TOP1MFILE;
print "done\n";

print "*******************************************************************\n";
print "Light blocklist created: $top1m_list ($top1m_count lines)\n";
print "Heavy blocklist created: $all_list ($all_count lines)\n";
print "*******************************************************************\n";

#EOF

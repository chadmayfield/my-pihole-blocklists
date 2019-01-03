#!/usr/bin/perl

# create_blocklist_porn.pl - create a pi-hole porn blocklist using public src

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

use strict;
use warnings;

use LWP::Simple;
use File::Fetch;
use File::Slurp;
use Archive::Tar;
use Archive::Zip;
use Array::Utils qw(:all);


# we'll save the lists in these two files
my $outfile = "pi_blocklist_porn_top1m.list";
my $allfile = "pi_blocklist_porn_all.list";

my $url1 = "http://s3.amazonaws.com/alexa-static/top-1m.csv.zip";
my $url2 = "ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/adult.tar.gz";

my @files;
my @matches;
my @compare;

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

print "extracting files\n";

# etract each file
foreach (@files) {
    my $filename = $_;
    my $suffix = ( split /\./, $filename )[-1];

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

            # get rid of any IP's or non-domain words
            my $regexp = '^(xxx|porn|adult|sex|\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$';

            open ALLFILE, ">", $allfile or die $!;

            # write all unmatched lines into tmpfile & load it into array
            for (@adult){
                my $tmpline = $_;
                next if ($_ =~ /$regexp/);
                # write to file
                print ALLFILE $tmpline;
                # load into array as well
                push @compare, $_;
            }

            close ALLFILE;

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
my @isect = intersect(@compare, @matches);

open OUTFILE, ">", $outfile or die $!;
print OUTFILE @isect;

# TODO: fix this temp hack to add subdomains, it's fugly!
for my $i (@isect) {
    print OUTFILE "www.${i}";
}

close OUTFILE;

print "counting lines...";
# get the line count for each line
my $count1;
open(FILE1, "< $allfile") or die "can't open $allfile: $!";
$count1++ while <FILE1>;
close FILE1;

# get the line count for each line
my $count2;
open(FILE2, "< $outfile") or die "can't open $outfile: $!";
$count2++ while <FILE2>;
close FILE2;
print "done\n";

print "*******************************************************************\n";
print "Light blocklist created: $outfile ($count2 lines)\n";
print "Heavy blocklist created: $allfile ($count1 lines)\n";
print "*******************************************************************\n";

#EOF

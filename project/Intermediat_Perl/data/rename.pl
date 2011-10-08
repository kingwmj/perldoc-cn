#!perl

use strict;
use warnings;
use 5.010;

my @filelist = glob("*.pod");

foreach my $file (@filelist) {
    my $newfile = $file;
    $newfile =~ s/\.pod$//;
    $newfile =~ s/(?:\.|\s+)/_/g;
    $newfile .= '.pod';
    rename $file, $newfile;
    say $newfile;
}


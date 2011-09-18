#!/usr/bin/perl

use strict;
use File::Basename;
use File::Find;

my (@filelist);
my $find_dir = "./POD";

find(\&wanted, $find_dir);
sub wanted {
	if ($_ =~ /\.(?:mod|pod|pm|pl)$/i) {
		push @filelist, $File::Find::name;
	}
}

foreach my $file (@filelist) {
	system "perl", "ppod2html", $file;
	print "perl ppod2html $file\n";
}


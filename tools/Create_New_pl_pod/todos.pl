#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use File::Find;
use File::Basename;

my(@filelist,$basename,$filename);
finddepth(\&wanted, './');
sub wanted {
	if ($_ =~ /\.pl$/) {
		push @filelist, $File::Find::name;
	}
}

foreach $filename (@filelist) {
	next if ($filename =~ /todos.pl/);
	$basename = basename($filename);
	open(OUTPUT, ">", "$filename.bat") or die $!;
	say OUTPUT "perl $basename\npause";
}

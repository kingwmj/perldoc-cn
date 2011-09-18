#!/usr/bin/perl -w

use strict;
use warnings;
use File::Find;
use Pod::Simple::RTF;
use 5.010;

my (@filelist);
my $find_dir = "./POD";

find(\&wanted, $find_dir);
sub wanted {
	if ($_ =~ /\.(?:mod|pod|pm|pl)$/i) {
		push @filelist, $File::Find::name;
	}
}

foreach my $file (@filelist) {
	say $file;
	my $parser = Pod::Simple::RTF->new();
	my $outfile = $file;
	$outfile =~ s/$/\.rtf/i;
	if (! -e $outfile) {
	open FH, $file or die $!;
	open OUTPUT, ">$outfile" or die $!;
	say "$file => $outfile";
	$parser->output_fh(*OUTPUT);
	$parser->parse_file(*FH);
}
}



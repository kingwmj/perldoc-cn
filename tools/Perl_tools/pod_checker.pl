#!perl

use warnings;
use strict;
use 5.010;

use Pod::Checker;

my $filepath = 'Simple.pod.new';
my $outputpath = "$filepath.err";
my %options = ();

my $syntax_okay = podchecker($filepath, $outputpath, %options);

my $checker = new Pod::Checker %options;
$checker->parse_from_file($filepath, \*STDERR);



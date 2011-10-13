#!perl

use strict;
use warnings;
use 5.010;
use File::Basename qw<basename>;
use File::Slurp qw<read_file write_file>;
use List::MoreUtils qw<zip>;

my $en = 'en\modern_perl_book\sections';
my $cn = 'cn\modern_perl_book\sections';
my $encn_dir = 'encn';
my @enfilelist = glob("$en/*.pod");
my @cnfilelist = glob("$cn/*.pod");

my %filelist = zip @enfilelist, @cnfilelist;

foreach my $enfile (keys %filelist) {
    my $cnfile = $filelist{$enfile};
    my $entext = read_file($enfile, binmode => ':utf8');
    my $cntext = read_file($cnfile, binmode => ':utf8');
    my $basename = basename $enfile;
    my $encnfile = "$encn_dir/$basename";
    write_file($encnfile, {binmode => ':utf8'}, "$entext$cntext")
}



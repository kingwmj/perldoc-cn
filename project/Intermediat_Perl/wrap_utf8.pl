#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use List::MoreUtils qw<zip>;
use File::Basename qw<basename>;

open(DEBUG, '>:utf8', 'DEBUG.pod');

my $indir = '05_tran_pod';
my $oudir = 'wrap';

my @filelist = glob("$indir/*.pod");
foreach my $file (@filelist) {
    my $basename = basename $file;
    my $oufile = "$oudir/$basename";
    open (my $fh_ou, '>:utf8', $oufile);
    open (my $fh_in, '<:utf8', $file);
    while (my $line = <$fh_in>) {
        chomp $line;
        $line =~ s/\s+$//;
        if ($line =~ /^\S/) {
            say {$fh_ou} wrap_utf8_text($line, 65);
            next;
        }
        say {$fh_ou} $line;
    }
}

sub wrap_utf8_text {
    my ($text, $column) = @_;
    my @chars = split //, $text;
    use bytes;
    my @length  = map { length $_ } @chars;
    my @lengths = map { $_ == 3 ? 2 : 1 } @length;
    no bytes;
    my $length;
    my @locations;
    foreach my $number (@lengths) {
        $length += $number;
        push @locations, $length;
    }
    my %location_char = zip @locations, @chars;
    sub bynumber { $a <=> $b }
    my $count = 0;
    my $wrap_text;
    foreach my $location (sort bynumber keys %location_char) {
        my $char = $location_char{$location};
        my $number = $location % $column;
        if ( ( $count == 1) and ( $number > ($column - 3)) ) {
            $wrap_text .= $char;
            next;
        }
        $count = 0 if ($number < 3 );
        $wrap_text .= $char;
        if ( $number >= ($column - 3) ) {
            $wrap_text .= "\n";
            $count = 1;
        }
    }
    $wrap_text =~ s/^\s+|\s+$//xmsg;
    return $wrap_text;
}

close DEBUG;

#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;

# ==============脚本功能介绍===============
# 解析 格式化字符串 
# =========================================

use File::Slurp qw< read_file write_file >;
use List::Util qw< shuffle >;

# 输出句柄
open (my $fh, '>:utf8', 'debug.txt');
# 定义替换字符串
my $elt = "\x{2264}"; # E<lt> => $elt
my $egt = "\x{2265}"; # E<gt> => $egt
my $lt  = "\x{226e}"; # '<' => $lt 
my $gt  = "\x{226f}"; # '>' => $gt
my @file = glob("en/*.pod");
my @all_format;
my $file = shuffle @file;
say $file;
#for my $file (@file) {
    my $text = read_file $file;
    # 先将文本中的转义字符串替换掉
    my $touch_elt_times = $text =~ s/E<lt>/$elt/g;
    my $touch_glt_times = $text =~ s/E<gt>/$egt/g;
    say "touch elt times is : $touch_elt_times";
    while (1) {
        my @format = $text =~ m/[BCFILSX]<[^<>]+>/mg;
#        say scalar(@format);
        last if (scalar @format == 0);
        $text =~ s/([BCFILSX])<([^<>]+)>/$1$lt$2$gt/mg;
        push @all_format, @format;
    }

    my @double_format = $text =~ m/[BCFILSX]<<+\s.*?\s>>+/mg;
    push @all_format, @double_format;
#}

use List::MoreUtils qw< uniq >;
uniq @all_format;
foreach (@all_format) {
    $_ =~ s/$elt/E<lt>/g;
    $_ =~ s/$egt/E<gt>/g;
    $_ =~ s/$lt/</g;
    $_ =~ s/$gt/>/g;
    say {$fh} $_;
}


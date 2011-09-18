#!perl

use strict;
use warnings;
use 5.014;

# ==============脚本功能介绍===============
#  
# =========================================

# 日期：Mon Aug 29 14:57:57 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

my @filelist = glob("*.pl");

foreach my $file (@filelist) {
    next if ($file =~ /rename2pod.pl/);
    my $podfile = $file;
    $podfile =~ s/\.pl$/.pod/;
    rename $file, $podfile;
    say "rename $file => $podfile";
}



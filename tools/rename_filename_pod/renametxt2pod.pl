#!perl

use strict;
use warnings;
use 5.014;

# ==============脚本功能介绍===============
#  
# =========================================

# 日期：Mon Aug 29 14:57:57 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

my @filelist = glob("*.txt");

foreach my $file (@filelist) {
    my $podfile = $file;
    $podfile =~ s/\.txt$/.pod/;
    rename $file, $podfile;
    say "rename $file => $podfile";
}



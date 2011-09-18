#!perl

use strict;
use warnings;
use 5.014;

# ==============脚本功能介绍===============
# 将unix平台上的文本文件重新格式化输出为
# windows 上的格式
# =========================================

# 日期：Mon Aug 29 14:46:32 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

my @filelist = glob("*.txt");
foreach my $input (@filelist) {
    my $output = "format_$input";
    open (my $fh, '<', $input) or die $!;
    open (my $out, '>', $output) or die $!;
    while (my $line = <$fh>) {
        #    chomp $line;
        print {$out} $line;
    }
}



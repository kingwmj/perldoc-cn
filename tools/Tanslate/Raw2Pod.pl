#!perl

use strict;
use warnings;
use 5.010;

# ==============脚本功能介绍===============
# 将非Pod原始文档转换成 Pod 文档格式
# =========================================

# 日期：Fri Sep  2 14:01:33 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

use File::Basename qw<basename>;
use File::Slurp qw<read_file write_file>;
use Text::Autoformat qw<autoformat>;

mkdir 'raw' unless (-e 'raw');
mkdir 'pod' unless (-e 'pod');

my @filelists = glob("raw/*.*");
foreach my $rawfile (@filelists) {
    my $podfile = basename $rawfile;
    $podfile =~ s/\.*$//; # 去除文件后缀名
    $podfile = "pod/$podfile.pod"; # 设置输出文件名
    my $rawtext = read_file($rawfile);
    my $formattext = autoformat $rawtext;
    write_file($podfile, $formattext);
}

print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


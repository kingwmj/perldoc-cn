#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use File::Basename qw<basename>;
use File::Slurp qw<read_file write_file>;
use ParseTools qw<split2sentence>;
my $blank = "\x{0020}";

# ==============脚本功能介绍===============
# 格式化 中级 Perl 的中英文对照内容 
# =========================================

open(DEBUG, '>:utf8', 'DEBUG.pod');

my $dir = 'format';
my @filelist = glob("$dir/*.pod");
foreach my $file (@filelist) {
    my $filename = basename $file;
    my $outfile = "split/$filename";
    my $text = read_file($file, binmode => ':utf8');
    my @en = $text =~ /^=EN\s.*?$/xmsg;
    my @cn = $text =~ /^=CN\s.*?$/xmsg;
    # 去除开头的标识符
    @en = map { s/^=EN\s// } @en;
    @cn = map { s/^=CN\s// } @cn;
    # 拆分成更小的段落
    @en = map { split2sentence($_) } @en;
    @cn = map { split2sentence($_) } @cn;

#    write_file($filename, { binmode => ':utf8' }, $text);
}

# ------------------------------------
# 文件运行结束标志
print "...Program Runnig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


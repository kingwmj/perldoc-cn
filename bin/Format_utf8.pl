#!perl

use strict;
use warnings;
use 5.014;

# ==============脚本功能介绍===============
# 将文件的编码按照两种编码转换成UTF8格式，
# 手工看正确的编码，远期可以判断能否正确翻译
# =========================================

# 日期：Thu Sep  1 16:54:54 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

use Encode;
use File::Basename;
use utf8;

mkdir 'gbk' unless (-e 'gbk');
mkdir 'utf8' unless (-e 'utf8');

my @filelist = glob("*.*");
foreach my $file (@filelist) {
    my $basefile = basename $file;
    my $gb2312_file = "gbk/$basefile";
    my $utf8_file   = "utf8/$basefile";
    open(my $fh_gb2312, '>', $gb2312_file) or die $!;
    open(my $fh_utf8,    '>', $utf8_file) or die $!;
    open(my $fh, '<', $file) or die $!;
    while (my $line = <$fh>) {
        chomp $line;
        say {$fh_utf8} $line;
        my $gb2312_decode_line = decode('gbk', $line);
        my $utf8_gb2312_encode = encode('utf8', $gb2312_decode_line);
        say {$fh_gb2312} $utf8_gb2312_encode;
    }
}

print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


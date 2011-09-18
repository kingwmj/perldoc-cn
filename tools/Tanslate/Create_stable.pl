#!perl
# ==============脚本功能介绍===============
#  创建测试用的stable文件
# =========================================
# 日期：Fri Sep  2 23:43:44 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

use strict;
use warnings;
use 5.010;
use autodie;
use Scalar::Util qw< readonly openhandle refaddr>;
use List::Util qw< max min maxstr sum reduce first shuffle>;
use List::MoreUtils qw< any all none notall pairwise each_array uniq>;
use File::Find;
use File::Basename qw< basename dirname >;
use File::Slurp qw< read_file >;
use Storable qw< store retrieve >;

my $dirname = 'storable';
mkdir $dirname unless ( -e $dirname );

foreach my $time (1..44) {
    my $randlength = int( rand(1) * 100 );
    my @randarray = ( 1 .. $randlength );
    store( \@randarray, $outfile );
}




print "...Runinig Over...\\n";
# vim:tw=78:ts=8:ft=perl:norl:


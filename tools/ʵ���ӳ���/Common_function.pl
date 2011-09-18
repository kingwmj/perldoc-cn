#!perl

use strict;
use warnings;
use 5.014;

# ==============脚本功能介绍===============
# 常用函数的使用  
# =========================================

# 日期：Wed Aug 31 10:48:23 2011
# 作者: 宋志泉 songzhiquan@hotmail.com
use List::MoreUtils;
use Scalar::Util qw< readonly openhandle refaddr>;
use List::Util qw< max min maxstr sum reduce first shuffle>;
use List::MoreUtils qw< any all none notall pairwise each_array uniq>;
use Devel::size qw< size total_size>;

# readonly() 如果自变量是不可修改的，就返回真值
# openhandle() 如果自变量是已开启的文件句柄，就返回真值
# refaddr() 返回引用的整数地址
# reftype() 返回引用的底层类型的字符串表达形式
my $max_number = max(0 .. 1000);
my $max_string = maxstr( qw( Fido Spot Rover ) );
my $sum = sum( 1 .. 1000 ); # 求和
my $product = reduce { $a * $b } 1 .. 1000;
my $found_a_match = first { $ > 1000 } @list;
# shuffle() 以伪随机次序返回其自变量
# uniq() 返回自变量列表并将重复着删除掉
my $found_a_match = any     { $_ > 1000 } @list;
my $all_greater   = all     { $_ > 1000 } @list;
my $none_greater  = none    { $_ > 1000 } @list;
# none() 如果其自变量都不为真，就返回真值
my $all_greater   = notall  { $_ % 2    } @list;
# notall() 如果有任何自变量为假，就返回真值
my @c = pairwise { $a + $b } @a, @b;
my $ea = each_array( @a, @b, @c );
my @d;
while (my ($a, $b, $c ) = $ea->() ) {
    push @d, $a + $b + $c;
}
my @odds = qw/1 3 5 7 9/;
my @evens = qw/2 4 6 8 10/;
my @numbers = mesh @odds, @even; # 返回1 2 3 4....
# size() 返回其自变量中用于存储数据的内存量
# total_size() 返回其自变量中用于存储数据及实现所需的内存量


print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


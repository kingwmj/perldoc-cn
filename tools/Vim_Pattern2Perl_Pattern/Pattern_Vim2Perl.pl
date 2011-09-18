#!perl

use strict;
use warnings;
use 5.014;

use File::Copy;

# ==============脚本功能介绍===============
# 将Vim Pattern flect to Perl Pattern
# 按照顺序进行替换，转换, 使用中间值进行替换
# =========================================

# 日期：Wed Aug 31 14:07:41 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

# Perl => Vim
my %pattern_perl = (
    '?' => '{-}',
    '\(' => '(',
    '\)' => ')',
    '\|' => '|',
    '\<' => '\b',
);

print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


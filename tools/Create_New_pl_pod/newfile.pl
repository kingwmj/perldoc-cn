#!perl

use strict;
use warnings;
use 5.010;

# ==============脚本功能介绍===============
#  
# =========================================

# 日期：Wed Sep 21 10:03:56 2011
# 作者: 宋志泉 songzhiquan@hotmail.com
# =========================================

use ModelTools qw<
      write_header
      write_end
      file_basename
      file_find
>;

write_header(); # 脚本开始部分

#file_basename(); # File::Basename qw<basename dirname>
file_find(); # File::Find qw<find>

write_end(); # 脚本结束部分

print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


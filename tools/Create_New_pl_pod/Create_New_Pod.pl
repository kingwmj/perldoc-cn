#!perl

use strict;
use warnings;
use 5.010;

# ==============脚本功能介绍===============
# 创建POD模版 
# =========================================

# 日期：Mon Aug 29 10:06:26 2011
# 作者: 宋志泉 songzhiquan@hotmail.com


my $newfilename = 'newfile.pod';
open (my $fh, '>', $newfilename) or die $!;
my $now = localtime();

say $fh <<EOF
=encoding utf8

# ============== POD 内容介绍===============
#  
# =========================================

# 日期：$now
# 作者: 宋志泉 songzhiquan\@hotmail.com

=head1 

=head2 

=head3 

=head3 

=cut
# vim:tw=78:ts=8:ft=pod:norl:

EOF


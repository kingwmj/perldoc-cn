#!perl

use strict;
use warnings;
use 5.010;
use ModelTools;

# ==============脚本功能介绍===============
#
# =========================================

# 日期：2011-08-28 09：51
# 作者: 宋志泉 songzhiquan@hotmail.com

my $newfilename = 'newfile.pl';
open (my $fh, '>', $newfilename) or die $!;
my $now = localtime();

print $fh <<EOF
#!perl

use strict;
use warnings;
use 5.010;

# ==============脚本功能介绍===============
#  
# =========================================

# 日期：$now
# 作者: 宋志泉 songzhiquan\@hotmail.com
# =========================================

use ModelTools qw<
      write_header
      write_end
EOF
;
my %export_ok = %{ModelTools::EXPORT_OK};
foreach my $sub (sort keys %export_ok) {
    say {$fh} "      $sub";
}
say $fh <<EOF
>;

write_header(); # 脚本开始部分
EOF
;

foreach my $sub (sort keys %export_ok) {
    my $intro = $export_ok{$sub};
    say {$fh} "#$sub(); # $intro";
    say $intro;
}

say $fh <<EOF

write_end(); # 脚本结束部分

print "...Runinig Over...\\n";
# vim:tw=78:ts=8:ft=perl:norl:
EOF
;
print "...Runing Over...\n";
__END__

#!perl
# vim:tw=78:ts=8:ft=perl:norl:
use strict;
use warnings;
use 5.010;

# ==============脚本功能介绍===============
# 正则表达式匹配 POD 中的 << word >> 结构 
# =========================================

# 日期：Sun Sep  4 18:09:10 2011
# 作者: 宋志泉 songzhiquan@hotmail.com
while (my $line = <DATA>) {
    chomp $line;
    my ($start_backet, $end_backet);
    if ($line =~ m/[CBILFSX](<+)/) {
        $start_backet = $1;
        ($end_backet = $start_backet) =~ tr/</>/;
        if ($line =~ m/[CBILFSX]$start_backet(.*?)$end_backet/) {
            say "line = $line";
            say "start_backet = $start_backet\nend_backet = $end_backet";
            say "touch = $1;"
        }
    }
}

# ------------------------------------
# 文件运行结束标志
print "...Program Runnig Over...\n";
__END__
__DATA__
C<< (?> [^()]+ ) >>
C<[^()]+ (?! [^()] )>


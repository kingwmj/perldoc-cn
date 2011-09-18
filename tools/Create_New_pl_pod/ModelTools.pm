package ModelTools;
# ========Start{{{
use strict;
use warnings;
use 5.010;
use autodie;
use Exporter;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(write_header write_end);      # 缺省输出的符号
our $VERSION   = 1.00;          # 版本号
our %EXPORT_OK = (
    file_find => 'File::Find qw<find>',
    file_basename => 'File::Basename qw<basename dirname>',
);
our @EXPORT_OK = keys %EXPORT_OK;  # 按要求输出的符号
# ==============脚本功能介绍===============
# 设置生成模块事例代码的函数功能
# =========================================

# 日期：Sat Sep  3 21:34:23 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

my $now = localtime();

my $output = 'newtem.pl';
open(my $fh, '>', $output);
# }}}
# ========write_header{{{
sub write_header {
    print {$fh} <<EOF
#!perl

use strict;
use warnings;
use 5.010;

# ==============脚本功能介绍===============
#  
# =========================================

# 日期：$now
# 作者: 宋志泉 songzhiquan\@hotmail.com

EOF
}
# }}}
# ========write_end{{{
sub write_end {
    print {$fh} <<'EOF'
# ------------------------------------
# 文件运行结束标志
print "...Program Runnig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:

EOF
}
# }}}
# ========File::Find{{{
sub file_find {
    print {$fh} <<'EOF'
# -------------------------------------
# 递归搜索目录下的文件
# -------------------------------------
use File::Find qw<find>;

my (@filelist); # 递归搜索的文件保存结果
my $find_dir = "POD"; # 默认搜索目录
mkdir $find_dir unless (-e $find_dir);
find(\&wanted, $find_dir);
sub wanted {
    if ($_ =~ /\.pod$/i) {
        push @filelist, $File::Find::name;
    }
}

EOF
};
# }}}
# ========File::Basename{{{
sub file_basename {
    print {$fh} <<'EOF'
# -------------------------------------
# 获取带路径文件名和路径名称
# -------------------------------------
use File::Basename qw<basename dirname>;

# $basename = basename $filename;
# $dirname  = dirname  $filename;

EOF
};
# }}}
# ========Model::Name{x{x{
sub model::name {
    print {$fh} <<'EOF'

EOF
};
# }x}x}

1;
# vim:tw=78:ts=8:ft=perl:norl:


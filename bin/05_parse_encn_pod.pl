#!perl

# --------------------------------------------------------
# 解析 ../04_encn_pod 目录中所有的 .pod 中英文对照格式文档，
# 输出到 ../dict/dict_sentence.dict 临时字典文件，保存编辑
# 结果，放置数据丢失
# --------------------------------------------------------

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use List::MoreUtils qw <uniq mesh>;
use ParseTools qw<findlist>;

# -----------------------------------
# 命令行处理
# -----------------------------------
my ($project_name) = @ARGV;
$project_name ||= 'sample';
my $project_dir = "../project/$project_name";
# ------------------------------------

my $encn_dir = "$project_dir/split";

my $blank = "\x{0020}";
open(DEBUG, '>', 'debug.pod');
# 从存档目录读取文件列表
my @filelist = findlist($encn_dir, qr/\.pod$/);
my %hash; # 所有的中英文对照资料
foreach my $file (@filelist) {
    say "Parse $file to data";
    open(my $fh, '<:utf8', $file);
    my(@en, @cn, %en_cn);
    while (my $line = <$fh>) {
        chomp $line;
        push @en, $line if ($line =~ s/^=EN\s//);
        push @cn, $line if ($line =~ s/^=CN\s//);
    }
    if ((scalar @en) == (scalar @cn)) {
        %en_cn = mesh @en, @cn;
    }
    else {
        say "Warning: $file En string is not equal with Cn string!";
        exit;
    }
    %hash = (%en_cn, %hash);
}

# 输出文档到 ../dict/dict_sentence.txt
my $output_file = "$project_dir/sentence.dict";
say "output file is: $output_file";
open(my $fh_out, '>:utf8', $output_file);
while (my ($en, $cn) = each %hash) {
    $en =~ s/^\s+|\s+$//g;
    $en =~ s/\s+/$blank/g;
    $en =~ s/\s*,\s*/,$blank/g;
    say {$fh_out} "$en||$cn";
}

close DEBUG;

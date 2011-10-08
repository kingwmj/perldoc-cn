#!perl

# --------------------------------------------------------
# 将 ../02_wrap_pod 文件夹中的POD文档的段落拆分成更小的句子
# 输出到 ../03_split_pod 文件夹的同名文件
# 拆分分隔符使用特别的字符，不使用这个模块，使用自己做的
# 操作符号。拆分中英文对照文件，按照指定的分隔符拆分。
# --------------------------------------------------------

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use List::MoreUtils qw <uniq mesh>;
use ParseTools qw<findlist split2sentence array2file clean_dir>;
use File::Basename qw<basename>;
use File::Slurp qw<read_file write_file>;

# -----------------------------------
# 命令行处理
# -----------------------------------
my ($project_name) = @ARGV;
$project_name ||= 'sample';
my $project_dir = "../project/$project_name";
# ------------------------------------

my $blank = "\x{0020}";
open(DEBUG, '>', 'debug.pod');

my $find_dir = "$project_dir/02_wrap_pod";
my $out_dir  = "$project_dir/03_split_pod";
# 清理目标文件夹
clean_dir($out_dir);

my @filelist = findlist($find_dir, qr/\.pod$/);
foreach my $file (@filelist) {
    # 进度指示器
    say "Start Parsing $file ...";
    my $basename = basename $file;
    my $outfile = "$out_dir/$basename";
    my @lines = read_file $file;
    @lines = uniq @lines;
    my @new_lines;
    foreach my $line (@lines) {
        # 去除行末换行符
        chomp $line;
        $line =~ s/\s+$//;
        # 忽略空行
        next if (length($line) == 0);
        # 如果非代码行和标题行，则进行拆分
        if ($line =~ /^[^\s=]+/) {
            $line =~ s/\s+/$blank/g; # 合并多余空格
            $line =~ s/\s*,\s*/,$blank/g; # 规范逗号
            my @split = split2sentence($line);
            push @new_lines, @split;
            next;
        }
        # 其余行不进行拆分
        push @new_lines, $line;
    }
    array2file(\@new_lines, $outfile);
}
close DEBUG;

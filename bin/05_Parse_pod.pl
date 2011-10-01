#!perl

# --------------------------------------------------------
# 1. 解析中英文对照格式，输出到 ../dict/dict_sentence.dict
# 2. 将 ../precess 文件夹中的POD文档的段落拆分成更小的句子
# --------------------------------------------------------

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use List::MoreUtils qw < uniq mesh >;

open(DEBUG, '>', 'debug.pod');
# 从存档目录读取文件列表
my @filelist = glob("../data/*.pod");
my %hash; # 所有的中英文对照资料
foreach my $podfile (@filelist) {
    say "Parse $podfile to data";
    open(my $fh, '<:utf8', $podfile);
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
        say "Warning: $podfile En string is not equal with Cn string!";
        exit;
    }
    %hash = (%en_cn, %hash);
}

# 输出文档到 ../dict/dict_sentence.txt
my $output_file = '../dict/sentence.dict';
say "output file is: $output_file";
open(my $fh_out, '>:utf8', $output_file);
while (my ($en, $cn) = each %hash) {
    say {$fh_out} "$en||$cn";
}

# 将precess文件夹中的文件进行进一步处理，拆分成更小的句子
use ParseTools qw<split2sentence array2file>;
use File::Basename qw<basename>;
use File::Slurp qw<read_file write_file>;

@filelist = glob("../precess/*.pod");
foreach my $file (@filelist) {
    # 进度指示器
    say "Start Parsing $file ...";
    my $basename = basename $file;
    my $outfile = "../split/$basename";
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
            my @split = split2sentence($line);
            push @new_lines, @split;
            next;
        }
        # 其余行不进行拆分
        push @new_lines, $line;
    }
    mkdir "../split" unless (-e "../split");
    array2file(\@new_lines, $outfile);
}
close DEBUG;

#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use File::Basename qw<basename>;
use File::Slurp qw<read_file write_file>;
use ParseTools qw<split2sentence>;
use List::MoreUtils qw<mesh zip>;
my $blank = "\x{0020}";

# ==============脚本功能介绍===============
# 格式化 中级 Perl 的中英文对照内容
# =========================================

open(DEBUG, '>:utf8', 'DEBUG.pod');
my %str = (
    ':' => '：',
    '.' => '。',
    '?' => '？',
    '!' => '！',
    ')' => '）',
    '(' => '（',
);

my %num = (
    'Ａ' => 'A',
    'Ｂ' => 'B',
    'Ｃ' => 'C',
    'Ｄ' => 'D',
    'Ｅ' => 'E',
    'Ｆ' => 'F',
    'Ｇ' => 'G',
    'Ｈ' => 'H',
    'Ｉ' => 'I',
    'Ｊ' => 'J',
    'Ｋ' => 'K',
    'Ｌ' => 'L',
    'Ｍ' => 'M',
    'Ｎ' => 'N',
    'Ｏ' => 'O',
    'Ｐ' => 'P',
    'Ｑ' => 'Q',
    'Ｒ' => 'R',
    'Ｓ' => 'S',
    'Ｔ' => 'T',
    'Ｕ' => 'U',
    'Ｖ' => 'V',
    'Ｗ' => 'W',
    'Ｘ' => 'X',
    'Ｙ' => 'Y',
    'Ｚ' => 'Z',
    '０' => '0',
    '１' => '1',
    '２' => '2',
    '３' => '3',
    '４' => '4',
    '５' => '5',
    '６' => '6',
    '７' => '7',
    '８' => '8',
    '９' => '9',
);
my $dir = 'format';
my @filelist = glob("$dir/*.pod");
foreach my $file (@filelist) {
    my $filename = basename $file;
    my $outfile = "split/$filename";
    open (my $fh_input,  '<:utf8', $file);
    open (my $fh_output, '>:utf8', $outfile);
    my @lines = <$fh_input>;
    foreach my $line (@lines) {
        chomp $line;
        if ($line =~ /^=EN\s/) {
            $line =~ s/\s+$//;
            say {$fh_output} $line;
            next;
        }
        if ($line =~ /^=CN\s/) {
            # 将中文全角数字符号转换成半角符号
            $line =~ s/(.)/(exists $num{$1}) ? $num{$1} : $1/ge;
            # 将句号后的空格去掉
            $line =~ s/\s*\.\s*/./g;
            # 将一些代码格式化显示
            my @word = $line =~ /[\$@%a-zA-Z0-9_\-><\s'":(){}\[\]]+/g;
            $line =~ s/([\$@%a-zA-Z0-9_\-><'":(){}\\\/\[\].]+)/(length($1) > 1) ? " I<$1> " : "$1"/ge;
            $line =~ s/\sI<CN>/CN/; # 恢复前导正文标识符
            $line =~ s/\s+/ /g; # 去除多余空格
            $line =~ s/\s+$//; # 去除尾部空格
            $line =~ s/\s*(.)$/(exists $str{$1}) ? $str{$1} : $1/ge;
            say DEBUG $line;
            say {$fh_output} $line;
#            say DEBUG "@word";
        }
    }
}

close DEBUG;

# ------------------------------------
# 文件运行结束标志
print "...Program Runnig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


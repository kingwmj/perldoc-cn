#!perl

use strict;
use warnings;
use 5.010;
use autodie;
use File::Basename qw< basename >;

# 预处理 C<Pod> 中的内容

# 调试模式，设置输出句柄
my $DEBUG = 1;
if ($DEBUG) {
   open(DEBUG, '>', 'debug.pod');
}

# 将字典数据加载到 %dict_hash 散列中
my (%dict_hash);
my $dict_code = '../dict/dict_code.txt';
foreach my $dict ($dict_code) {
	open(my $fh_dict, '<', $dict);
	while (<$fh_dict>) {
		chomp;
		if ($_ =~ /\|\|/) {
			my($key, $value) = split(/\|\|/, $_);
			$dict_hash{$key} = $value;
		}
	}
}

my $blank = "\x{0020}";
my @filelist = glob("../en/*.pod");
mkdir "../precess" unless (-e "../precess");
foreach my $podfile (@filelist) {
    my $filename = basename $podfile;
    my $outfile  = "../precess/$filename";
	open(my $fh_in,  '<', $podfile);
    # 输出句柄以 utf8 为编码
    open(my $fh_out, '>', $outfile);
    say {$fh_out} "=encoding utf8\n";
    my $count = 0;
    my $text = "";
    while (my $line = <$fh_in>) {
        chomp $line;
        # 预处理部分
        $line =~ s/\s+$//;      # 去除尾部空格
        if ($line =~ /^$/) {
            say {$fh_out} "$text\n";
            $text = "";
            next;
        }
        # 如果代码不以空格开始进行替换
        if ($line =~ /\S/) {
            $line =~ s/\s+/$blank/g; # 两个以上空格替换成一个
            $line =~ s/\s*,\s*/,$blank/g; # 逗号后加一个空格
            $line =~ s/\s*\.\s*/./g; # 句号后不能留空格
        }
        # 如果以代码格式开始，原样输出非空行
        if ($line =~ /^\s/) {
            say {$fh_out} $text;
            $text = "";
        }
        # 行内容保存起来
        $text .= "$line ";
    }
}

close DEBUG;

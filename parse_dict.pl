#!perl

use strict;
use warnings;
use File::Find;
use 5.010;

# 解析指定文本文件,pod文件，将文本中所有涉及到的单词制作成字典
# 将已认识字典中涉及的单词排除，将不认识的单词在不认识
# 字典中找出，并将在字典中不存在的单词单独列出来。
# 通过有道查询来完善字典。

my $find_dir = 'input/';
say "Get the argument of $find_dir";

my(@filelist, %wordlist, %dict_hash);
my(%dict_all, %dict_known, %dict_study, %dict_code);
# define dict filename
my $dict_all   = 'dict/dict.txt';
my $dict_known = 'dict/dict_know.txt';
my $dict_study = 'dict/dict_study.txt';
my $dict_code = 'dict/dict_code.txt';

# load the %dict_hash from dict
foreach my $dict ($dict_all, $dict_known, $dict_study, $dict_code) {
	open(DICT, $dict) or die $!;
	while(<DICT>) {
		chomp;
		if ($_ =~ /\|\|/) {
			my($key, $value) = split(/\|\|/, $_);
			$dict_all{$key}   = $value if ($dict eq $dict_all);
            $dict_known{$key} = $value if ($dict eq $dict_known);
            $dict_study{$key} = $value if ($dict eq $dict_study);
            $dict_code{$key}  = $value if ($dict eq $dict_code);

		}
	}
}

# 测试这几个字典，生成测试脚本，
# get all the file list would be parse
find(\&wanted, $find_dir);
sub wanted {
	if ($_ =~ /\.(pod|txt)$/i) {
		push @filelist, $File::Find::name;
	}
}

# 解析文本
foreach my $file ( @filelist ) {
	say "Starting parse file $file ...";
	open(FILE, $file) or warn "Can not open $file: $!\n";
	while ( my $line = <FILE> ) {
		chomp $line;
		next if ($line =~ m/^\s+/); # 过滤注释
		$line =~ s/\W|\d/ /g; # 将非字母和数字替换成空格
		$line =~ s/\s+|_/ /g; # 将下划线和多个空格替换成单个空格
		my @line = split / /, $line; # 拆分
		foreach my $word (@line) {
			$word = lc($word);
			my $length = length($word);
			$wordlist{$word} = $word if ($length > 1);
		}
	}
}
# 设置三个字典，一个是常用的，不需要翻译的，
# 一个是需要翻译的，另外一个是忽略不需要翻译的。
#
# output waitting confirm dict
my $wait_confm = 'dict/wait_confirm.txt';
my $debug_file = 'dict/touched.txt';
open(OUTPUT, ">", $wait_confm) or die $!;
open(DEBUG, ">", $debug_file) or die $!;
sub byword { $a cmp $b }
foreach my $key (sort byword keys %wordlist) {
	if (exists $dict_hash{$key}) {
		say DEBUG  "$key||$dict_hash{$key}";
	}
	else {
		say OUTPUT $key;
	}
}
say "Parsing Over!";

# 去除下划线'_', 非单词字符，数字，和单字符单词
# 加载完全的字典，加载不必翻译的字典系列
# load dict_all and dict_know
# compare the wordlist result is not touched two dict

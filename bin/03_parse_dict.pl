#!perl

# ---------------------------------------------------
# 1. 将 common.dict 中在 ignore.dict 中已有的记录删除
# 2. 将 ../precess 目录中的文本中的单词列表提取出来，
#    将没有在 common.dict && ignore.dict 中没有的记录
#    提取出来，保存为单词列表 rare.dict
# ---------------------------------------------------

use strict;
use warnings;
use 5.010;
use utf8;
use Encode;
use autodie;
use File::Find qw<find>;
use Lingua::EN::Splitter qw<words>;
use File::Slurp qw<read_file>;
use ParseTools qw<dict2hash hash2dict filter_format_str filter_ignore_str>;
use List::MoreUtils qw<uniq>;
use File::Basename qw<basename>;

# 重写 Lingua::EN::Splitter->words 方法，使之区分大小写
BEGIN {
    no warnings 'redefine';
    *Lingua::EN::Splitter::words = sub {
        my $self = shift;
        my $input = shift;
        $input =~ s/$self->{PARAGRAPH_BREAK}/ /g;
        return [ split /$self->{NON_WORD_CHARACTER}+/, $input ];
    }
}

# 调试句柄
open (DEBUG, '>:utf8', 'debug.pod');

# 字符串定义
my $blank = "\x{0020}"; # 空格

# 扫描目录并获取所有文件列表
my $find_dir = '../precess'; # 直接从预处理的文件夹中找
my @filelist; # 目录中所有的 pod && txt 文档

# 获取文件列表
find(\&wanted, $find_dir);
sub wanted {
	if ($_ =~ /\.(pod|txt)$/i) {
		push @filelist, $File::Find::name;
	}
}

# 定义基本字典变量
my $dict_dir = '../dict';
my $file_dict_common  = "$dict_dir/common.dict"; # 单词列表
my $file_dict_simple  = "$dict_dir/simple.dict"; # 忽略单词

# 将单词字典加载为散列
my $ref_dict_common = dict2hash($file_dict_common);
my $ref_dict_simple = dict2hash($file_dict_simple);
my %dict_common = %{$ref_dict_common};
my %dict_simple = %{$ref_dict_simple};
my %dict_hash = (%dict_common, %dict_simple);

# 遍历专有名词，如普通单词列表中有，则删除普通单词记录
foreach my $key (keys %dict_simple) {
	if (exists $dict_common{$key}) {
		delete $dict_common{$key};
		say "exists $key in common dict";
	}		
}

# 重新保存普通单词列表
hash2dict(\%dict_common, $file_dict_common);

# 解析文本，生成单词列表，同时生成代码单词表
my (%wordlist);
foreach my $file ( @filelist ) {
    # 进度提示
	say "Starting parse file $file ...";
    my $text = read_file $file;

    # 提取所有不需要翻译字符串列表
    my $ref_array_format_str = filter_format_str($file);
    my $ref_array_ignore_str = filter_ignore_str($file);
    my @conceal_str = (@{$ref_array_format_str}, @{$ref_array_ignore_str});

    # 将不需要翻译的字符串列表替换掉
    foreach my $string (@conceal_str) {
        $text =~ s/\Q$string\E/$blank/g;
    }
    say DEBUG $text;

    # 生成单词表散列，标注文件名
    my $filename = basename $file;
    $filename =~ s/\..*$//;
    foreach my $word (@{ words($text) }) {
        $wordlist{$word} = $filename;
    }
}

# 规范 %wordlist 单词散列
# 将纯数字 单词长度小于2，连续的字母单词剔除
foreach my $word (keys %wordlist) {
    # 去除包含数字的单词
    delete $wordlist{$word} if ( $word =~ /[0-9_]/ );
    # 去除只有一个字母的单词
    delete $wordlist{$word} if ( length($word) < 2 );
    # 去除重复一个字母的单词
    delete $wordlist{$word} if ( $word =~ /^(\w)\1+$/ );
}

# 匹配单词列表
my (%dict_rare);
foreach my $key (sort keys %wordlist) {
	if (not exists $dict_hash{$key}) {
        my $filename = $wordlist{$key};
        # 如果没有匹配上，就加入不匹配散列
		$dict_rare{$key} = " ";
	}
}

# 输出不匹配结果
my $file_dict_rare = "$dict_dir/rare.dict";
if (scalar %dict_rare) {
    hash2dict(\%dict_rare, $file_dict_rare);
}
close DEBUG;

say "Parsing Over!";

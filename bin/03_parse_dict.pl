#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use File::Find qw< find >;
use Lingua::EN::Splitter qw( words );
use Pod::Simple::Text;
use File::Slurp qw< read_file >;

my $podparser = new Pod::Simple;

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
open (my $fh_debug, '>', 'debug.pod');
my $blank = "\x{0020}";

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
my $file_dict_common  = "$dict_dir/dict_common.txt";
my $file_dict_rare    = "$dict_dir/dict_rare.txt";

# 定义存储字典内部变量
my(%dict_hash, %dict_common, %dict_rare);
foreach my $file ($file_dict_common, $file_dict_rare) {
	open(my $fh, '<', $file);
	while (my $line = <$fh>) {
        chomp $line;
		if ($line =~ /\|\|/) {
			my($key, $value) = split /\|\|/, $line;
            $dict_hash{$key} = $value;
            $dict_common{$key} = $value if ($file eq $file_dict_common);
            $dict_rare{$key}   = $value if ($file eq $file_dict_rare);
		}
	}
}

# 对比 %dict_common && %dict_rare, 如果有重复就删除 %dict_common 中的记录
foreach my $key (keys %dict_common) {
    delete $dict_common{$key} if ( exists $dict_rare{$key} );
}

# 将没有同 %dict_rare %dict_code 重复的记录输出为新的 dict_common.txt
open (my $fh_common, '>', $file_dict_common);
foreach my $word (sort keys %dict_common) {
    say {$fh_common} "$word||$dict_common{$word}";
}

# 解析文本，生成单词列表，同时生成代码单词表
my (%wordlist);
foreach my $file ( @filelist ) {
	say "Starting parse file $file ...";
    my $text = read_file($file);
    # 替换掉整个文件中的格式化字符串
    $text = format_text($text);
    # 集中显示POD
    say {$fh_debug} $text;
    # 生成单词表
    $wordlist{$_}++ for @{ words($text) };
}

# 规范 %wordlist 单词散列
foreach my $word (keys %wordlist) {
    # 去除包含数字的单词
    delete $wordlist{$word} if ( $word =~ /[0-9_]/ );
    # 去除只有一个字母的单词
    delete $wordlist{$word} if ( length($word) < 2 );
    # 去除重复一个字母的单词
    delete $wordlist{$word} if ( $word =~ /^(\w)\1+$/ );
}

# 匹配单词列表
my (%dict_unknown);
foreach my $key (sort keys %wordlist) {
	if (!exists $dict_hash{$key}) {
        # 如果没有匹配上，就加入不匹配散列
		$dict_unknown{$key} = '';
	}
}

# 输出不匹配结果
my $file_dict_unknown = "$dict_dir/dict_unknown.txt";
open(my $fh_unknown, '>', $file_dict_unknown);
foreach my $word (sort keys %dict_unknown) {
    say {$fh_unknown} $word;
}

say "Parsing Over!";

# 使用递归替换将代码中的格式字符串替换掉，结果生成单词表
# 并存储到专门的数组中, 按照标记格式保存
# 从长到短保存，用 Pod::simple 模块解析文本，保存为散列。
# 以便进行恢复和高亮显示
# 提取替换掉的内容到一个数组
sub format_text {
    my $text = shift;
    # 将注释替换掉
    $text =~ s/^\s+.*?$//xmsg;
    # 替换掉格式化字符串，嵌套三层的替换三次
    $text =~ s/[BCEILFSX]<<\s.*?\s>>//sg;
    $text =~ s/[BCEILFSX]<[^<]+>/0/sg;
    $text =~ s/[BCEILFSX]<[^<]+>/0/sg;
    $text =~ s/[BCEILFSX]<[^<]+>/0/sg;
    
    # 将变量名称替换掉
    $text =~ s/\$\w+//g;
    # 将函数名称替换掉
    $text =~ s/\w+\(\d*\)//g;
    # 在行末加空格
    $text =~ s/$/$blank/g;
    # 去掉行首的空格
    $text =~ s/^\s+//g;
    # 替换掉空行
    $text =~ s/(^\s*$)+//xmsg;

    return $text;
}


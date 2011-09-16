#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use File::Find qw< find >;
use Lingua::EN::Splitter qw( words );
use Pod::Simple;

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
my $tab   = $blank x 4;

# 扫描目录并获取所有文件列表
my $find_dir = 'en';
my @filelist; # 目录中所有的 pod && txt 文档

# 获取文件列表
find(\&wanted, $find_dir);
sub wanted {
	if ($_ =~ /\.(pod|txt)$/i) {
		push @filelist, $File::Find::name;
	}
}

# 定义基本字典变量
my $dict_dir = 'dict';
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
my $file_dict_code  = "$dict_dir/dict_code.txt";
my (%wordlist);
foreach my $file ( @filelist ) {
	say "Starting parse file $file ...";
	open(my $fh, '<', $file);
    my $blank_line = 0; # 空行计数
    my $text; # 局部缓冲，每个文件一个累加标量
	while ( my $line = <$fh> ) {
		chomp $line;
        $line =~ s/\s+$//; # 去除行后空格
        
        # 忽略文本
		next if ($line =~ m/^\s+/); # 忽略原文输出部分
        next if ($line =~ m/^=encoding/); # 忽略 =encoding 行
        next if ($line =~ m/^=over/);
        next if ($line =~ m/^=back/);
        next if ($line =~ m/^=cut/);
        next if ($line =~ m/^=for/);
        next if ($line =~ m/^=item\s+\*$/);
        next if ($line =~ m/^=item\s+\d+$/);

        # 预处理文本
        $line =~ s/^=head[1234]\s+//; # 去除 =head 标题标记
        $line =~ s/^=item\s+//; # 去除 =item 标记
        $line =~ s/\s+/$blank/g; # 将多个空格合并成一个空格
 
        # 将连续的空行合并成一行
        $blank_line++   if     ($line =~ /^$/);
        $blank_line = 0 unless ($line =~ /^$/);
        next if ($blank_line > 1);

        # 保存输出到变量
        $line =~ s/$/$blank/; # 末尾添加空格，可以没有标点符号的标题单独成词
        $text .= $line;

        # 集中显示POD
        say {$fh_debug} $line;
    }

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

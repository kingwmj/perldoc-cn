#!perl

use strict;
use warnings;
use 5.010;
use autodie;
use File::Find qw< find >;

open(DEBUG, '>', 'debug.txt');

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
my $file_dict_code    = "$dict_dir/dict_code.txt";

# 定义存储字典内部变量
my(%dict_hash, %dict_common, %dict_rare, %dict_code);
foreach my $file ($file_dict_common, $file_dict_rare, $file_dict_code) {
	open(my $fh, '<', $file);
	while (my $line = <$fh>) {
        chomp $line;
		if ($line =~ /\|\|/) {
			my($key, $value) = split /\|\|/, $line;
            $dict_hash{$key} = $value;
            $dict_common{$key} = $value if ($file eq $file_dict_common);
            $dict_rare{$key}   = $value if ($file eq $file_dict_rare);
            $dict_code{$key}   = $value if ($file eq $file_dict_code);
		}
	}
}

# 对比三个字典看是否有重复
foreach my $key (keys %dict_common) {
    say DEBUG "$key in common also in rare" if ( exists $dict_rare{$key} );
    say DEBUG "$key in common also in code" if ( exists $dict_code{$key} );
}

# 解析文本，生成单词列表
my (%wordlist);
foreach my $file ( @filelist ) {
	say "Starting parse file $file ...";
	open(my $fh, '<', $file);
	while ( my $line = <$fh> ) {
		chomp $line;
		next if ($line =~ m/^\s+/); # 过滤注释
		$line =~ s/\W|\d/ /g; # 将非字母和数字替换成空格
		$line =~ s/\s+|_/ /g; # 将下划线和多个空格替换成单个空格
		my @line = split / /, $line; # 拆分
		foreach my $word (@line) {
			$word = lc($word);
			my $length = length($word);
			$wordlist{$word} = '';
		}
	}
}

# 匹配单词列表
my (%dict_unknown, %dict_know);
foreach my $key (sort keys %wordlist) {
	if (exists $dict_hash{$key}) {
        # 如果匹配上，就加入匹配散列
        $dict_know{$key} = $dict_hash{$key};
	}
	else {
        # 如果没有匹配上，就加入不匹配散列
		$dict_unknown{$key} = '';
	}
}

# 输出结果
my $file_dict_know    = "$dict_dir/dict_know.txt";
my $file_dict_unknown = "$dict_dir/dict_unknown.txt";

open(my $fh_know,    '>', $file_dict_know);
open(my $fh_unknown, '>', $file_dict_unknown);

# 输出匹配结果
foreach my $word (sort keys %dict_know) {
    say {$fh_know} "$word||$dict_hash{$word}";
}

# 输出不匹配结果
foreach my $word (sort keys %dict_unknown) {
    say {$fh_unknown} $word;
}

say "Parsing Over!";

# 去除下划线'_', 非单词字符，数字，和单字符单词
# 加载完全的字典，加载不必翻译的字典系列

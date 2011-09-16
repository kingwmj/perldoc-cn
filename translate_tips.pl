#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

# Parse text 
# No need Parse text: =code ... = code_end
# Special Chars Do not need transfer <>
# Number do not need transfer
# load two dict of all and no need three dict
# one: dict_study
# two: dict_know
# three: dict_code

# argument can get from commands input
my($input_file) = $ARGV[0];
# if no argument, default file is input.txt
$input_file ||= 'input.txt';

my(@result_array, %dict_hash, $dict_file);
# dictionary file is dict_file.txt
$dict_file = 'dict_file.txt';
# load the %dict_hash from dict
open(DICT, $dict_file) or die $!;
while(<DICT>) {
	chomp;
	if ($_ =~ /\|\|/) {
		my($key, $value) = split(/\|\|/, $_);
		$dict_hash{$key} = $value;
	}
}
my $output_file = 'output.txt';
open(OUTPUT, ">$output_file") or die $!;
# Parse txt
open(INPUT, $input_file) or die $!;
while(my $line = <INPUT>) {
	chomp $line;
	my @words_list = $line =~ /\w+/g; # parse the line to array @word_list
	push @result_array, @words_list;  # push all the line to @result_array
	# if the line touched the dict, output the result
	if (exists $dict_hash{$line}) {
		say OUTPUT $dict_hash{$line};
	} else {
		# if the line not touched the dict, then parse line to sentense
		my @sentences = split(/\./, $line);
		foreach my $sentence (@sentences) {
			if (exists $dict_hash{$sentence}) {
				print OUTPUT $dict_hash{$sentence}, '.';
			} else {
				my @phrases = split(/,/, $sentence);
				foreach my $phrase (@phrases) {
					if (exists $dict_hash{$phrase}) {
						print OUTPUT $dict_hash{$sentence}, '.';
					} else {
						my @words = split(/\s+/, $phrase);
						foreach my $word (@words) {
							if (exists $dict_hash{$word}) {
								print OUTPUT $dict_hash{$word}. ' ';
							} else {
								print OUTPUT $word, '(?) ';
							}
						}
					}
				}
			}
		}
		print OUTPUT "\n";
	}
}

foreach my $key (@result_array) {
	$key =~ s/^\s+|\s+$//g;
	$dict_hash{$key} = '';
}

foreach my $key (sort bychar keys %dict_hash) {
	say OUTPUT "$key||";
}

sub bychar { $a cmp $b }
# 解析整个文本，将单词提取出来，制作词典
# 解析整个文本，将短语提取出来，制作短语索引
# 解析整个文本，将句子提取出来，制作句子索引
# 对于各种标点符号， 该如何解析呢？
# 如何恢复原文的各种标点符号呢？
# 是否应该制作段落的索引呢？甚至是文章的索引呢？
# 如何将现成的翻译资源变成可用的资源呢？
# 将文本解析成字典，然后，查阅没有翻译的资源，然后，将不懂的单词标注。
#

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
    }
    
    # 替换掉整个文件中的格式化字符串
#    $text = format_text($text);
    # 集中显示POD
    say {$fh_debug} $text;
    # 生成单词表
    $wordlist{$_}++ for @{ words($text) };
}




#!/usr/bin/perl

# -----------------------
# 将POD翻译成中文编辑格式
# -----------------------

use strict;
use warnings;
use 5.010;
use ParseTools qw<dict2hash array2hash filter_conceal_string>;
use File::Slurp qw<read_file write_file>;
use List::MoreUtils qw<uniq mesh pairwise>;
use File::Basename qw<basename>;
use utf8;

open(DEBUG, '>:utf8', 'debug.pod');

# 加载整句匹配词典
my $dict_sentence = '../dict/sentence.dict'; # 整句词典
my $dict_phrase = '../dict/phrase.dict'; # 短语字典

# 将字典文件转换成散列引用
my $ref_hash_dict_sentence = dict2hash($dict_sentence, $dict_phrase);
my %hash_dict_sentence = %{$ref_hash_dict_sentence};

# 加载普通单词词典，直接替换
my $dict_common = '../dict/common.dict';
# 加载专用词词典，直接替换
my $dict_code = '../dict/code.dict';
my $ref_hash_dict_common = dict2hash($dict_common);
my $ref_hash_dict_code   = dict2hash($dict_code);

# 生僻词，字典中没有的记录 abrogate(？) 使用？进行标注
my $dict_rare = '../dict/rare.dict';
my $ref_hash_dict_rare = dict2hash($dict_rare);

my @filelist = glob("../precess/*.pod");

# 按照键值长度输出
sub bylength { length($b) <=> length($a) };

# 遍历文件列表
foreach my $file ( @filelist ) {
    
    # 进度指示
    say "Starting parse file $file ...";
    my $text = read_file $file;
    
    # 建立编辑模式副本
    my $bak_text = $text;
    
    # 开始全文段落短语替换
    foreach my $en_sentence (sort bylength keys %hash_dict_sentence) {
        my $cn_sentence = $hash_dict_sentence{$en_sentence};
        my $en_sentence = qr/\Q$en_sentence\E/;
        my $times = $text =~ s/$en_sentence/$cn_sentence/g;
#        say DEBUG "replaced $times times" if ($times > 0);
    }
    # 将不需要翻译的内容先提取出来
    my $ref_conceal_array = filter_conceal_string($file);
    my $ref_conceal_hash = array2hash($ref_conceal_array);
    my %conceal_hash = %{$ref_conceal_hash};
    my $count = scalar %conceal_hash;
#    say DEBUG "filter $count conceal string ..";
    foreach my $char (keys %conceal_hash) {
        say DEBUG "<$char>";
    }

    # 隐藏代码字符
    foreach my $string (sort bylength keys %conceal_hash) {
        next if ($string eq '');
        my $char = $conceal_hash{$string};
        my $times = $text =~ s/\Q$string/$char/g;
#        say DEBUG "Conceal string replaced $times times" if ($times > 0);
    }

    # 专有名词替换
    while (my ($word, $char) = each %{$ref_hash_dict_code}) {
        my $times = $text =~ s/\b$word\b/$char/g;
#        say DEBUG "common word replaced $times times" if ($times > 0);
    }

    # 常用单词替换
    while (my ($word, $char) = each %{$ref_hash_dict_common}) {
        my $times = $text =~ s/\b$word\b/$char/g;
#        say DEBUG "common word replaced $times times" if ($times > 0);
    }
    
    # 生僻单词替换
    while (my ($word, $char) = each %{$ref_hash_dict_rare}) {
        my $times = $text =~ s/\b$word\b/$word($char)/g;
#        say DEBUG "Rare word touched $times times" if ($times > 0);
    }
    
    # 恢复隐藏字符
    foreach my $string (keys %conceal_hash) {
        my $char = $conceal_hash{$string};
        my $times = $text =~ s/$char/$string/g;
        # say DEBUG "recover $times times" if ($times > 0);
    }

    # 输出对比结果
    my @en_lines = split /\n+/, $bak_text;
    my @cn_lines = split /\n+/, $text;
	
	# 剔除没有注释的代码
	@en_lines = grep { ! /^\s[^#]+$/ } @en_lines;
	@cn_lines = grep { ! /^\s[^#]+$/ } @cn_lines;
    my @en_cn_lines = pairwise { "=EN $a\n\n=CN $b\n" } @en_lines, @cn_lines;
    
    # 输出翻译结果
    my $basename = basename $file;

    # 输出编辑结果
    my $edit_file = "../edit/$basename";
	open(my $fh_out, '>:utf8', $edit_file);
	say {$fh_out} "=encoding utf8\n";
	foreach my $line (@en_cn_lines) {
		say {$fh_out} $line;
	}	
}

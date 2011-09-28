#!/usr/bin/perl

# -----------------------
# 将POD翻译成中文编辑格式
# -----------------------

use strict;
use warnings;
use 5.010;
use ParseTools qw<dict2hash array2hash %header filter_conceal_string>;
use File::Slurp qw<read_file write_file>;
use List::MoreUtils qw<uniq mesh>;
use File::Basename qw<basename>;
use utf8;

open(DEBUG, '>', 'debug.pod');

# 加载整句匹配词典
my $dict_sentence = '../dict/dict_sentence.dict'; # 整句词典
my $dict_phrase = '../dict/dict_phrase.dict'; # 短语字典

# 将字典文件转换成散列引用
my $ref_hash_dict_sentence = dict2hash($dict_sentence, $dict_phrase);
my %hash_dict_sentence = %{$ref_hash_dict_sentence};

# 加载普通单词词典，解释唯一的单词，直接替换
my $dict_common = '../dict/dict_common.dict';
my $ref_hash_dict_common = dict2hash($dict_common);

# 生僻词，有多个解释，替换后，进行备注 abrogate(取消，废除)
my $dict_rare = '../dict/dict_rare.dict';
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
    my $edit_text = $text;
    
    # 开始全文段落短语替换
    foreach my $en_sentence (sort bylength keys %hash_dict_sentence) {
        my $cn_sentence = $hash_dict_sentence{$en_sentence};
        my $times = $text =~ s/\Q$en_sentence\E/$cn_sentence/go;
        say "sentence replace $times times" if ($times > 0);
    }
    
    # 将不需要翻译的内容先提取出来
    my $ref_conceal_array = filter_conceal_string($file);
    my %conceal_hash = array2hash($ref_conceal_array);
    my $count = scalar %conceal_hash;
    say "filter $count conceal string ..";
    foreach my $key (keys %conceal_hash) {
        say DEBUG "<$key>";
        $key =~ s/\s+$//;
        next if ($key =~ /^$/);
        my $value = $conceal_hash{$key};
#        say DEBUG "$key => $value";
    }
    
    # 隐藏代码字符
    foreach my $string (sort bylength keys %conceal_hash) {
        my $char = $conceal_hash{$string};
        my $times = $text =~ s/\Q$string\E/$char/go;
        say "replace conceal string $times times" if ($times > 0);
    }
    
    # 常用单词替换
    while (my ($word, $char) = each %{$ref_hash_dict_common}) {
        my $times = $text =~ s/\b$word\b/$char/go;
        say "common word replace $times times" if ($times > 0);
    }
    
    # 生僻单词替换
    while (my ($word, $char) = each %{$ref_hash_dict_rare}) {
        my $times = $text =~ s/\b$word\b/$word($char)/go;
        say "rare word replace $times times" if ($times > 0);
    }
    
    # 恢复隐藏字符
    foreach my $string (keys %conceal_hash) {
        my $char = $conceal_hash{$string};
        my $times = $text =~ s/$char/$string/g;
        say "recover conceal string $times times" if ($times > 0);
    }
    
    # 输出翻译结果
    my $basename = basename $file;

    # 输出编辑结果
    my $edit_file = "../edit/$basename";
    #write_file($edit_file, { bimode => ':utf8' }, $text);
}

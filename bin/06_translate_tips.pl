#!/usr/bin/perl

# -------------------
# 将POD翻译成中文格式
# -------------------

use strict;
use warnings;
use 5.010;
use ParseTools qw< dict2hash array2hash %header filter_conceal_string >;
use File::Slurp qw< read_file write_file >;
use List::MoreUtils qw< uniq mesh >;
use Lingua::Sentence;
use utf8;

#open(DEBUG, '>', 'debug.pod');

# 加载整句匹配词典
my $dict_sentence = '../dict/dict_sentence.txt'; # 整句词典
my $dict_phrase = '../dict/dict_phrase.txt'; # 短语字典

# 将字典文件转换成散列引用
my $ref_hash_dict_sentence = dict2hash($dict_sentence, $dict_phrase);
my %hash_dict_sentence = %{$ref_hash_dict_sentence};

# 加载普通单词词典，解释唯一的单词，直接替换
my $dict_common = '../dict/dict_common.txt';
my $ref_hash_dict_common = dict2hash($dict_common);

# 生僻词，有多个解释，替换后，进行备注 abrogate(取消，废除)
my $dict_rare = '../dict/dict_rare.txt';
my $ref_hash_dict_rare = dict2hash($dict_rare);

my @filelist = glob("../precess/*.pod");
# 按照键值长度输出
sub bylength { length($b) <=> length($a) };
# 遍历文件列表
foreach my $file ( @filelist ) {
	say "Starting parse file $file ...";
    my $text = read_file $file;
    # 建立编辑模式和翻译模式的副本
    my $edit_text = $text;
    my $tran_text = $text;
    # 开始全文段落短语替换
    foreach my $sentence (sort bylength keys %hash_dict_sentence) {
        $sentence = quotemeta $sentence;
        my $translate = $hash_dict_sentence{$sentence};
        $tran_text =~ s/$sentence/$translate/go;
    }
    # 将不需要翻译的内容先提取出来
    my $ref_conceal_array = filter_conceal_string($text);
    my %conceal_hash = array2hash(@{$ref_conceal_array});
    # 隐藏代码字符
    foreach my $string (sort bylength keys %conceal_hash) {
        $string = quotemeta $string;
        my $char = $conceal_hash{$string};
        $text =~ s/$string/$char/go;
    }
    # 常用单词替换
    while (my ($word, $char) = each %{$ref_hash_dict_common}) {
        $text =~ s/$word/$char/go;
    }
    # 生僻单词替换
    while (my ($word, $char) = each %{$ref_hash_dict_rare}) {
        $text =~ s/$word/$word($char)/go;
    }
    # 恢复隐藏字符
    foreach my $string (keys %conceal_hash) {
        my $char = $conceal_hash{$string};
        $text =~ s/$char/$string/g;
    }
    # 输出翻译结果
    my $basename = basename $file;
    my $tran_file = "../tran/$basename";
    write_file($tran_file, $tran_text);
    # 输出编辑结果
    my $edit_file = "../edit/$basename";
    write_file($edit_file, $edit_text);
}



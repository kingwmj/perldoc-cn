#!perl

# ----------------------------------------------
# 将POD翻译成中文文档和中英文对照编辑文档
# 解析 ../precess 中的 Pod 文档，
# 1）替换 ../dict/sentence.dict 中的段落
# 2）替换 ../dict/head.dict 中的标题
# ----------------------------------------------

use strict;
use warnings;
use 5.010;
use ParseTools qw<dict2hash array2hash filter_format_str filter_ignore_str>;
use File::Slurp qw<read_file write_file>;
use List::MoreUtils qw<uniq mesh>;
use File::Basename qw<basename>;
use utf8;

open(DEBUG, '>:utf8', 'debug.pod');
my $blank = "\x{0020}";

# 加载整句匹配词典
my $dict_sentence = '../dict/sentence.dict'; # 整句词典

# 将字典文件转换成散列引用
my $ref_hash_dict_sentence = dict2hash($dict_sentence);
my %hash_dict_sentence = %{$ref_hash_dict_sentence};

# 加载普通单词词典，直接替换
my $dict_common = '../dict/common.dict';
my $ref_hash_dict_common = dict2hash($dict_common);
my %hash_dict_common = %{$ref_hash_dict_common};

# 加载忽略单词词典，首字母大写替换
my $dict_simple = '../dict/simple.dict';
my $ref_hash_dict_simple = dict2hash($dict_simple);
my %hash_dict_simple = %{$ref_hash_dict_simple};

my @filelist = glob("../split/*.pod");
#my @filelist = glob("../pod/*.pod");

# 按照键值长度输出
sub bylength { length($b) <=> length($a) };

# 遍历文件列表
foreach my $file ( @filelist ) {
    
    # 进度指示
    say "Starting parse file $file ...";
    my $text = read_file $file;
    
    # 输出翻译结果
    my $basename = basename $file;

    # 将不需要翻译的内容先提取出来
    my $ref_format_array = filter_format_str($file);
    my $ref_ignore_array = filter_ignore_str($file);
    my $ref_format_hash = array2hash($ref_format_array);
    my $ref_ignore_hash = array2hash($ref_ignore_array);
    my %format_hash = %{$ref_format_hash};
    my %ignore_hash = %{$ref_ignore_hash};
    my %conceal_hash = (%format_hash, %ignore_hash);

    # 备份原始英文文档 $tran -> 全文翻译结果，保留格式
    my $tran = $text;

    # 剔除 =head =item =over ... code 等格式化字符
    say "Replace head token and code string ...";
    foreach my $string (sort bylength keys %format_hash) {
        next if ($string eq '');
        my $char = $format_hash{$string};
        $text =~ s/^\Q$string//msg;
    }

    foreach my $key (keys %format_hash) {
#        say DEBUG $key;
    }

    # 格式化 $text 去除空格
    $text =~ s/$blank+/$blank/msg;
    $text =~ s/$blank*,$blank*/,$blank/msg;
    $text =~ s/$blank+$//msg;
    say DEBUG $text;
    # 备份中间结果
    my $no_format_en_text = $text;

    # 开始全文段落短语替换
    say "Replace Sentence in dict ...";
    foreach my $en_sentence (sort bylength keys %hash_dict_sentence) {
        my $cn_sentence = $hash_dict_sentence{$en_sentence};
        $tran =~ s/\Q$en_sentence\E/$cn_sentence/xmsg;
        $text =~ s/\Q$en_sentence\E/$cn_sentence/xmsg;
    }
    
    # 输出翻译结果
    my $tran_file = "../tran/$basename";
	write_file($tran_file, {binmode => ':utf8'}, $tran);

    # 释放已经不用的变量，清理内存
    undef $tran;
    undef $tran_file;

    # 专有字符 C<> http ftp email var func file 暂时隐藏
    say "Replace ignore string ...";
    foreach my $string (sort bylength keys %ignore_hash) {
        next if ($string eq '');
        my $char = $ignore_hash{$string};
        $text =~ s/\Q$string/$char/g;
    }

    # 普通单词替换
    foreach my $word (sort bylength keys %hash_dict_common) {
        my $char = $hash_dict_common{$word};
        $text =~ s/\b$word\b/$char/g;
    }

    # 简单单词替换
    while (my ($word, $char) = each %hash_dict_simple) {
        $text =~ s/\b$word\b/ucfirst($word)/ge;
    }
    
    # 恢复隐藏字符
    foreach my $string (keys %conceal_hash) {
        my $char = $conceal_hash{$string};
        $text =~ s/$char/$string/g;
    }

    # 输出对比结果
    my @en_lines = split /\n+/, $no_format_en_text;
    my @cn_lines = split /\n+/, $text;

    # 剔除没有内容的空行
    @en_lines = grep { ! /^\s*$/ } @en_lines;
    @cn_lines = grep { ! /^\s*$/ } @cn_lines;
	
	# 剔除没有注释的代码
	@en_lines = grep { ! /^\s[^#]+$/ } @en_lines;
	@cn_lines = grep { ! /^\s[^#]+$/ } @cn_lines;
    
    # 合并中英文数组为散列
    my %mesh = mesh @en_lines, @cn_lines;
    # 删除键和值相等的散列元素
    while (my ($en, $cn) = each %mesh) {
        delete $mesh{$en} if ($en eq $cn);
    }

    # 按照前后顺序输出散列的中英文对照值
    my @en_cn_lines;
    foreach my $en (@en_lines) {
        if (exists $mesh{$en}) {
            my $cn = $mesh{$en};
            push @en_cn_lines, "=EN $en\n\n=CN $cn\n";
        }
    }

    # 输出编辑结果
    my $edit_file = "../edit/$basename";
	open(my $fh_out, '>:utf8', $edit_file);
	foreach my $line (@en_cn_lines) {
		say {$fh_out} $line;
	}	
}

close DEBUG;

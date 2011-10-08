#!perl

# ----------------------------------------------
# 将POD翻译成中文文档和中英文对照编辑文档
# ----------------------------------------------

use strict;
use warnings;
use 5.010;
use ParseTools qw<dict2hash array2hash findlist
                  filter_format_str filter_ignore_str>;
use File::Slurp qw<read_file write_file>;
use List::MoreUtils qw<uniq mesh>;
use File::Basename qw<basename>;
use utf8;

# -----------------------------------
# 命令行处理
# -----------------------------------
my ($project_name) = @ARGV;
$project_name ||= 'sample';
my $project_dir = "../project/$project_name";
# ------------------------------------
#my $input_dir = "$project_dir/03_split_pod";
my $input_dir = "$project_dir/02_wrap_pod";
my $encn_dir  = "$project_dir/04_encn_pod";
my $tran_dir  = "$project_dir/05_tran_pod";

my @filelist = findlist($input_dir, qr/\.pod$/);

open(DEBUG, '>:utf8', 'debug.pod');
my $blank = "\x{0020}";

# 加载整句匹配词典
my $dict_sentence = '../dict/sentence.dict'; # 整句词典
my $proj_sentence = "$project_dir/sentence.dict"; # 项目整句词典

# 将字典文件转换成散列引用
my %hash_dict_sentence = dict2hash($dict_sentence);
my %hash_proj_sentence = dict2hash($proj_sentence);

# 删除项目词典中已有的记录
while (my ($en, $cn) = each %hash_dict_sentence) {
    if (exists $hash_proj_sentence{$en}) {
        say "Find an exists record in Core Sentence Dict";
        delete $hash_proj_sentence{$en};
        my $cn_proj = $hash_proj_sentence{$en};
    }
}

# 合并整句词典
%hash_dict_sentence = (%hash_proj_sentence, %hash_dict_sentence);

# 加载普通单词词典，直接替换
my $dict_common = '../dict/common.dict';
my %hash_dict_common = dict2hash($dict_common);

# 加载忽略单词词典，首字母大写替换
my $dict_simple = '../dict/simple.dict';
my %hash_dict_simple = dict2hash($dict_simple);

# 按照键值长度输出
sub bylength { length($b) <=> length($a) };

# 遍历文件列表
foreach my $file ( @filelist ) {
    
    # 进度指示
    say "Translate $file ...";
    my $text = read_file $file;
    
    # 输出翻译结果
    my $basename = basename $file;

    # 将不需要翻译的内容先提取出来
    my @format_array = filter_format_str($file);
    my @ignore_array = filter_ignore_str($file);
    my %ignore_hash = array2hash([@ignore_array]);
    my %format_hash = array2hash([@format_array]);

    # 隐藏 =head =item =over ... code 等格式化字符
    say "Replace head token and code string ...";
    foreach my $string (sort bylength keys %format_hash) {
        next if ($string eq '');
        my $char = $format_hash{$string};
#        say DEBUG "<$string>=><$char>";
        $text =~ s/^\Q$string\E/$char/xmsgi;
    }

    # 格式化 $text 去除空格
    $text =~ s/$blank+/$blank/msg;
    $text =~ s/$blank*,$blank*/,$blank/msg;
    $text =~ s/$blank+$//msg;

    # 备份中间结果
    my $no_format_en_text = $text;

    # 开始全文段落短语替换
    say "Replace Sentence in dict ...";
    foreach my $en_sentence (sort bylength keys %hash_dict_sentence) {
        my $cn_sentence = $hash_dict_sentence{$en_sentence};
        # 忽略单词大小写的替换
        $text =~ s/\Q$en_sentence\E/$cn_sentence/ixmsg;
    }

    # 恢复隐藏字符
    say "Recovery the format string ...";
    foreach my $string (keys %format_hash) {
        my $char = $format_hash{$string};
        $text =~ s/$char/$string/g;
    }
    
    # 输出翻译结果
    my $tran_file = "$tran_dir/$basename";
	write_file($tran_file, {binmode => ':utf8'}, $text);
    next;

    # 释放已经不用的变量，清理内存
    undef $tran_file;

    # 专有字符 C<> http ftp email var func file 暂时隐藏
    say "Replace ignore string ...";
    foreach my $string (sort bylength keys %ignore_hash) {
        next if ($string eq '');
        my $char = $ignore_hash{$string};
        $text =~ s/\Q$string\E/$char/g;
    }

    # 普通单词替换
    say "Replace Word tips ....";
    foreach my $word (sort bylength keys %hash_dict_common) {
        my $char = $hash_dict_common{$word};
        $text =~ s/\b$word\b/$char/ig;
    }

    # 简单单词替换
    say "Repalce Simple words with Ucfirst word ...";
    while (my ($word, $char) = each %hash_dict_simple) {
        $text =~ s/\b$word\b/ucfirst($word)/ige;
    }
    
    # 恢复隐藏字符
    say "Recovery the ignore string ...";
    foreach my $string (keys %ignore_hash) {
        my $char = $ignore_hash{$string};
        $text =~ s/$char/$string/g;
    }

    # 输出对比结果
    say "Split the Text with line end";
    my @en_lines = split /\n+/, $no_format_en_text;
    my @cn_lines = split /\n+/, $text;

    # 剔除没有内容的空行
    say "Abandon the line with no content ...";
    @en_lines = grep { ! /^\s*$/ } @en_lines;
    @cn_lines = grep { ! /^\s*$/ } @cn_lines;
	
	# 剔除没有注释的代码
    say "Abandon the code without comments ...";
    @en_lines = grep { ! /^\s[^#]+$/ } @en_lines;
    @cn_lines = grep { ! /^\s[^#]+$/ } @cn_lines;
    say "not equal array" unless (scalar @en_lines == scalar @cn_lines);
    
    # 合并中英文数组为散列
    my %mesh = mesh @en_lines, @cn_lines;
    # 删除键和值相等的散列元素
    say "Delete the line don't need translate ..";
    while (my ($en, $cn) = each %mesh) {
#        say DEBUG $en unless (defined $cn);
        delete $mesh{$en} if ($en eq $cn);
    }

    # 按照前后顺序输出散列的中英文对照值
    say "Output the En & Cn line translated ...";
    my @en_cn_lines;
    my $encn_file = "$encn_dir/$basename";
	open(my $fh_out, '>:utf8', $encn_file);

    foreach my $en (@en_lines) {
        if (exists $mesh{$en}) {
            my $cn = $mesh{$en};
            say {$fh_out} "=EN $en\n\n=CN $cn\n";
        }
    }
}

close DEBUG;

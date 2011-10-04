#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use File::Slurp qw<read_file write_file>;
use File::Basename qw <basename>;
use ParseTools qw<dict2hash hash2dict>;

# ---------------------------------------------------
# 格式化所有的后缀为 dict 的字典，中文去除英文标点符号
# 英文部分去除中文标点符号
# ---------------------------------------------------

my $blank = "\x{0020}";
open(my $debug, '>', 'debug.pod');

# 定义基本字典变量
my $dict_dir = '../dict';
my $file_dict_common   = "$dict_dir/common.dict"; # 单词列表
my $file_dict_simple   = "$dict_dir/simple.dict"; # 忽略单词
my $file_dict_sentence = "$dict_dir/sentence.dict"; # 句子词典

# 将单词字典加载为散列
my %dict_common   = dict2hash($file_dict_common);
my %dict_simple   = dict2hash($file_dict_simple);
my %dict_sentence = dict2hash($file_dict_sentence);

# 遍历句子词典，如忽略单词列表中有，则删除记录
foreach my $key (keys %dict_sentence) {
	if (exists $dict_simple{$key}) {
		delete $dict_simple{$key};
		say "delete $key in simple dict";
	}		
}

# 遍历简单名词，如普通单词记录中有，则删除记录
foreach my $key (keys %dict_simple) {
	if (exists $dict_common{$key}) {
		delete $dict_common{$key};
		say "delete $key in common dict";
	}		
}

# 格式化带中文词典
my $ref_dict_common   = format_dict(\%dict_common);
my $ref_dict_sentence = format_dict(\%dict_sentence);
hash2dict($ref_dict_common,   $file_dict_common);
hash2dict($ref_dict_sentence, $file_dict_sentence);
hash2dict({%dict_simple},     $file_dict_simple);

# 替换散列里中文的非全角标点符号
# 替换散列里英文的全角标点符号
sub format_dict {
    my $ref_dict_hash = shift;
    my %dict_hash = %{$ref_dict_hash};
    state $tokens = {
    ',' => '，',
    '!' => '！',
    '?' => '？',
    ':' => '：',
    ';' => '；',
    '(' => '（',
    ')' => '）',
    };
    foreach my $en_string (keys %dict_hash ) {
        my $cn_string = $dict_hash{$en_string};
        # 将前后的空格去掉
        $en_string =~ s/^\s+|\s+$//;
        $cn_string =~ s/^\s+|\s+$//;
        $en_string =~ s/\s+/$blank/g;
        # 遍历标点符号，实行替换
        foreach my $en_token (keys %{$tokens}) {
            my $cn_token = ${$tokens}{$en_token};
            $en_string =~ s/$cn_token/$en_token/g;
            $cn_string =~ s/\Q$en_token\E/$cn_token/g;
        }
        $dict_hash{$en_string} = $cn_string;
    }
    return \%dict_hash;
}


say "Script Running over, Pls enter to back.";

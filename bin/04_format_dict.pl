#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;

# ----------------------------------
# 格式化所有的字典和中英文对照文档
# ----------------------------------

use File::Slurp qw< read_file write_file >;
use File::Basename qw <basename>;
use ParseTools qw< dict2hash hash2dict >;

open(my $debug, '>', 'debug.pod');
my $dict_dir = '../dict';
my @dict_filelist = glob("$dict_dir/*.dict");

# 将 ../dict/目录下所有的 .dict 字典文件中的标点符号格式化
foreach my $dict_file (@dict_filelist) {
    my $filename = basename $dict_file;
    my $ref_dict_hash = dict2hash($dict_file);
    my $ref_new_dict_hash = format_dict($ref_dict_hash);
    hash2dict($ref_new_dict_hash, $dict_file);
}

# 替换散列里中文的非全角标点符号
# 替换散列里英文的全角标点符号
sub format_dict {
    my $ref_dict_hash = shift;
    my %dict_hash = %{$ref_dict_hash};
    state $tokens = {
    ',' => '，',
    '.' => '。',
    '!' => '！',
    '?' => '？',
    ':' => '：',
    ';' => '；',
    '(' => '（',
    ')' => '）',
    };
    foreach my $en_string (keys %dict_hash ) {
        my $cn_string = $dict_hash{$en_string};
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

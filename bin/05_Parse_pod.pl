#!perl
# --------------------------------
# 用中英文的格式对照表解析出来
# 输出到 ../dict/dict_sentence.txt
# --------------------------------
use strict;
use warnings;
use 5.010;
use autodie;
use List::MoreUtils qw < mesh zip >;

# 调试模式，设置输出句柄
my $DEBUG = 0;
if ($DEBUG) {
   open(OUT, '>', 'debug.pod');
}

# 从存档目录读取文件列表
my @filelist = glob("../data/*.pod");
my %hash; # 所有的中英文对照资料
foreach my $podfile (@filelist) {
    open(my $fh, '<', $podfile);
    my(@en, @cn, %en_cn);
    while (my $line = <$fh>) {
        chomp $line;
        push @en, $line if ($line =~ s/^=EN\s//);
        push @cn, $line if ($line =~ s/^=CN\s//);
    }
    if ((scalar @en) == (scalar @cn)) {
        %en_cn = mesh @en, @cn;
    }
    else {
        say "Warning: $podfile En string is not equal with Cn string!";
        exit;
    }
    %hash = (%en_cn, %hash);
}

# 输出文档到 ../dict/dict_sentence.txt
my $output_file = '../dict/dict_sentence.txt';
open(my $fh_out, '>', $output_file);
while (my ($en, $cn) = each %hash) {
    say {$fh_out} "$en||$cn";
}

# 将中文翻译的结果中的标点符号全部替换成
# 全角中文符号
my %tokens = (
    ',' => '',
    '.' => '',
);

sub format_cn_string {
    my @array = @_;
    foreach my $string (@array) {
        foreach my $token (keys %tokens) {
            my $cn_token = $tokens{$token};
            $string =~ s/$token/$cn_token/g;
        }
    }
    return @array;
}


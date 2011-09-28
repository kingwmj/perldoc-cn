#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;

# ==============脚本功能介绍===============
# 第一步 解析 格式化字符串 将解析结果，保存
# 为文本，然后可以再次加载
# =========================================

use File::Slurp qw< read_file >;

# 输出句柄
my $output_file = '../dict/dict_format.txt';
open (my $fh, '>', $output_file);
# 定义替换字符串
my $elt = "\x{2264}"; # E<lt> => $elt
my $egt = "\x{2265}"; # E<gt> => $egt
my $lt  = "\x{226e}"; # '<' => $lt 
my $gt  = "\x{226f}"; # '>' => $gt
my @file = glob("../en/*.pod");
my @all_format;
#my $file = shuffle @file;
#say $file;
for my $file (@file) {
    say "parse $file .....";
    my $text = read_file $file;
    my @double_format = $text =~ m/[BCFILSX]<<+\s.*?\s>>+/mg;
    push @all_format, @double_format;

    # 先将文本中的转义字符串替换掉
    $text =~ s/E<lt>/$elt/g;
    $text =~ s/E<gt>/$egt/g;
    while (1) {
        my @format = $text =~ m/[BCFILSX]<[^<>]+>/mg;
#        say scalar(@format);
        last if (scalar @format == 0);
        $text =~ s/([BCFILSX])<([^<>]+)>/$1$lt$2$gt/mg;
        push @all_format, @format;
    }

}
# 恢复替换结果
use List::MoreUtils qw< uniq mesh >;
uniq @all_format;
foreach (@all_format) {
    $_ =~ s/$elt/E<lt>/g;
    $_ =~ s/$egt/E<gt>/g;
    $_ =~ s/$lt/</g;
    $_ =~ s/$gt/>/g;
    $_ =~ s/\n/ /g;
}

# 生成和格式化字符串相同数量的字符列表
my @conceal;
my $number = scalar @all_format;
foreach my $key (1 .. $number) {
    my $hex = sprintf("&&%.4x", $key);
    push @conceal, $hex;
}
# 所有的映射字符串格式是 &&0110101011&&
# 合并两个数据类型相同的数组 使用 |jesus|做为分隔符
my %format_conceal = mesh @all_format, @conceal;
foreach my $code (sort keys %format_conceal)  {
    say {$fh} "$code||$format_conceal{$code}";
}

# 单目操作符和二进制匹配，从长到短的匹配。
say "Output file: $output_file";

__END__

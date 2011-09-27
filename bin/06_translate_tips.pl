#!/usr/bin/perl

# -------------------
# 将POD翻译成中文格式
# -------------------

use strict;
use warnings;
use 5.010;
use File::Slurp qw< read_file >;
use List::MoreUtils qw< uniq mesh >;
use Lingua::Sentence;
use utf8;

#open(DEBUG, '>', 'debug.pod');
# 加载匹配词典
my $dict_sentence = '../dict/dict_sentence.txt'; # 短句词典
my $dict_head = '../dict/dict_head.txt'; # 标题词典

# 将字典文件列表数据加载到替换散列中
my %dict_hash;
foreach my $file ($dict_sentence, $dict_head) {
    my $text = read_file $file;
    my @lines = split /\n/, $text;
    foreach (@lines) {
        if ($_ =~ /\|\|/) {
            my ($key, $value) = split(/\|\|/, $_);
		    $dict_hash{$key} = $value;
        }
    }
}

# 标记语言散列
my %header = (
    '=head1 '    => "\x{2460}",
    '=head2 '    => "\x{2461}",
    '=head3 '    => "\x{2462}",
    '=head4 '    => "\x{2463}",
    '=item '     => "\x{2465}",
    '=begin '    => "\x{2469}",
    '=for '      => "\x{2466}",
    '=back'      => "\x{2467}",
    '=encoding'  => "\x{2464}",
    '=over'      => "\x{2468}",
    '=end'       => "\x{2474}",
    '=cut'       => "\x{2475}",
    '=pod'       => "\x{2476}",
);

# 按照键值长度输出
sub bylength { length($b) <=> length($a) };
my @filelist = glob("../precess/*.pod");
my @pods;
foreach my $file ( @filelist ) {
	say "Starting parse file $file ...";
    my $text = read_file $file;
    # 将不需要翻译的内容先替换成特殊字符
    # 将代码部分分离出来
    open (my $fh, '<', $file);
    my @codes;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^\s/) { # 如果是代码行
            $line =~ s/\s#.*$//; # 将注释部分删除
            push @codes, $line;
        }
    }
    my $ref_conceal_codes = array2hash(@codes);
    my %conceal = (%header, %{$ref_conceal_codes});
    # 隐藏代码字符
    foreach my $string (sort bylength keys %conceal) {
        my $char = $conceal{$string};
        $string = quotemeta $string;
        $text =~ s/$string/$char/g;
    }
    # 开始全文替换


    # 恢复隐藏字符
    foreach my $string (keys %conceal) {
        my $char = $conceal{$string};
        $text =~ s/$char/$string/g;
    }
    write_file('debug.pod', $text);
}

my $splitter = Lingua::Sentence->new("en");
foreach my $sentence (@pods) {
    my $split = $splitter->split($sentence);
    my @split = split /\n/, $split;
    foreach my $line (@split) {
        chomp $line;
        # say DEBUG "($line)";
    }
}

# 生成和格式化字符串相同数量的字符列表
sub array2hash {
    my @array = @_;
    my @conceal;
    my $number = scalar @array;
    @conceal = map { sprintf("&&%0.4x", $_) } (1 .. $number);
    # 合并两个数据类型相同的数组
    my %format_conceal = mesh @array, @conceal;
    return \%format_conceal;
}


package ParseTools;

require Exporter;

our @ISA = qw( Exporter );
our @EXPORT = qw< %header %chars >;
our @EXPORT_OK = qw < dict2hash hash2dict array2hash split2sentence
                      bylength format_cn_string >;
our @VERSION = 1.00;

use strict;
use warnings;
use 5.010;
use autodie;
use File::Slurp qw< read_file >;
use List::MoreUtils qw< mesh uniq >;
use Lingua::Sentence;

# 标记语言临时替换散列
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

# 定义替换字符串
my %chars  = (
    "E<lt>" => "\x{2264}",
    "E<gt>" => "\x{2265}",
    "<"     => "\x{226e}",
    ">"     => "\x{226f}",
);


# 字典转换成散列 my $ref_dict_hash = dict2hash($file1, $file2);
sub dict2hash {
    my @filelist = @_;
    my %dict_hash;
    foreach my $file (@filelist) {
        my $text = read_file $file;
        my @lines = split /\n/, $text;
        foreach my $line (@lines) {
        if ($line =~ /\|\|/) {
            my ($key, $value) = split /\|\|/, $line;
		    $dict_hash{$key} = $value;
        }
    }
    return \%dict_hash;
}

# 将字符串数组转换成映射字符散列
sub array2hash {
    my @array = @_;
    @array = uniq @array;
    my @conceal;
    my $number = scalar @array;
    @conceal = map { sprintf("&&%0.4x", $_) } (1 .. $number);
    # 合并两个数据类型相同的数组
    my %array2hash = mesh @array, @conceal;
    return \%array2hash;
}

# 将一个数组拆分成按照句子的数组
sub split2sentence {
    my @array = @_;
    my $splitter = Lingua::Sentence->new("en");
    my @split = map { $splitter->split_array($_) } @array;
    return \@split;
}

# 将散列保存为字典文件 hash2dict(\%hash, $dict_name);
sub hash2dict {
    my ($ref_hash, $filename) = @_;
    my %dict_hash = %{$ref_hash};
    open (my $fh, '>', $filename);
    foreach my $key (sort keys %dict_hash) {
        my $value = $dict_hash{$key};
        say {$fh} "$key||$value";
    }
    return 1;
}

# 按照键值长度输出
sub bylength { length($b) <=> length($a) };

# 全角中文符号
my %tokens = (
    ',' => '，',
    '.' => '。',
);

# 将中文翻译的结果中的标点符号全部替换成
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

1;

package ParseTools;

require Exporter;

our @ISA = qw( Exporter );
our @EXPORT = qw< %header %chars >;
our @EXPORT_OK=qw< dict2hash hash2dict array2hash split2sentence
                   format_cn_string filter_conceal_string >;
our @VERSION = 1.00;

use strict;
use warnings;
use 5.010;
use autodie;
use File::Slurp qw< read_file write_file>;
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
        my @lines = read_file($file, binmode => ':utf8');
        foreach my $line (@lines) {
            chomp $line;
            if ($line =~ /\|\|/) {
                my ($key, $value) = split /\|\|/, $line;
                $dict_hash{$key} = $value;
            }
        }
    }
    return \%dict_hash;
}

# 将字符串数组转换成映射字符散列
sub array2hash {
    my $ref_array = shift;
    my @array = uniq @{$ref_array};
    my $number = scalar @array;
    my @conceal = map { sprintf("&&%0.4x", $_) } (1 .. $number);
    # 合并两个数据类型相同的数组
    my %array2hash = mesh @array, @conceal;
    return %array2hash;
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
    my $text;
    foreach my $key (sort keys %dict_hash) {
        my $value = $dict_hash{$key};
        $text .= "$key||$value\n";
    }
    write_file($filename, { binmode => ':utf8' }, $text);
    return 1;
}

# 将Pod文档中的不需要翻译的字符串数组提取成数组
sub filter_conceal_string {
    my $file = shift;
    my $text = read_file $file;
    my (@head, @double_format, @format, @code);
    # 获取 =head =over =item 等结构数组
    @head = $text =~ /^=\w+\s+/xmsg;

    # 替换掉注释
    $text =~ s/^(\s+.*?)#.*?$/$1/xmsg;
    # 获取每行前有空格的代码原文格式数组
    @code = $text =~ /^\s+.*?$/xmsg;

    # 中间替换变量
    my $elt = "\x{2264}"; # E<lt> => $elt
    my $egt = "\x{2265}"; # E<gt> => $egt
    my $lt  = "\x{226e}"; # '<' => $lt 
    my $gt  = "\x{226f}"; # '>' => $gt
    @double_format = $text =~ m/[BCFILSX]<<+\s.*?\s>>+/mg;

    # 先将文本中的转义字符串替换掉
    $text =~ s/E<lt>/$elt/g;
    $text =~ s/E<gt>/$egt/g;
    while (1) {
        my @array = $text =~ m/[BCFILSX]<[^<>]+>/mg;
        last if (scalar @format == 0);
        $text =~ s/([BCFILSX])<([^<>]+)>/$1$lt$2$gt/mg;
        push @format, @array;
    }
    # 恢复替换结果
    my @all_format = (@double_format, @format);
    uniq @all_format;
    foreach (@all_format) {
       $_ =~ s/$elt/E<lt>/g;
       $_ =~ s/$egt/E<gt>/g;
       $_ =~ s/$lt/</g;
       $_ =~ s/$gt/>/g;
       $_ =~ s/\n/ /g;
   }
   my @return_array = (@head, @code, @all_format);
   return \@return_array;
}

1;

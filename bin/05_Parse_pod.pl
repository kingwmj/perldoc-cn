#!perl
# 替换掉能够翻译的段落，将不能翻译的段落
# 用中英文的格式列出来
use strict;
use warnings;
use 5.010;
use autodie;
use File::Basename qw< basename >;
use File::Slurp qw< read_file write_file >;

# 断句模块
use Lingua::Sentence qw<>;
my $splitter = Lingua::Sentence->new("en");

# 调试模式，设置输出句柄
my $DEBUG = 0;
if ($DEBUG) {
   open(OUT, '>', 'debug.pod');
}

# 将字典数据加载到 相应散列中
sub file2hash {
    my $filename = shift;
    my %dict_hash;
    open(my $fh_dict, '<', $filename);
	while (<$fh_dict>) {
		chomp;
		if ($_ =~ /\|\|/) {
			my($key, $value) = split(/\|\|/, $_);
			$dict_hash{$key} = $value;
		}
	}
    close $fh_dict;
    return \%dict_hash;
}

# 加载普通生僻，格式化字符字典
my $dict_common = '../dict/dict_common.txt';  # 常用词字典
my $ref_dict_common = file2hash($dict_common);
my $dict_rare = '../dict/dict_rare.txt'; # 生僻字字典
my $ref_dict_rare = file2hash($dict_rare);
my $dict_format  = '../dict/dict_format.txt';  # 代码字典，无须翻译
my $ref_dict_format = file2hash($dict_format);
my $dict_head = '../dict/dict_head.txt'; # 标题字典
my $ref_dict_head = file2hash($dict_head);

# 标记语言散列
my %header = (
    '=head1 '     => "\x{2460}",
    '=head2 '     => "\x{2461}",
    '=head3 '     => "\x{2462}",
    '=head4 '     => "\x{2463}",
    '=item '      => "\x{2465}",
    '=begin '     => "\x{2469}",
    '=for '       => "\x{2466}",
#    '=back'      => "\x{2467}",
#    '=encoding'  => "\x{2464}",
#    '=over'      => "\x{2468}",
#    '=end'       => "\x{2474}",
#    '=cut'       => "\x{2475}",
#    '=pod'       => "\x{2476}",
);

my @header = keys %header; # 标题标记语言列表
my @heads  = keys %{$ref_dict_head};
my @replace_list = (@header, @heads); # 合并替换标题列表
# 从预处理目录获取文件目录
my @filelist = glob("../precess/*.pod");
foreach my $podfile (@filelist) {
    my $filename = basename $podfile;
    # 设置手工翻译目录
    my $outfile  = "../translate/$filename";
    my $text = read_file $podfile;
    foreach my $tag (@replace_list) {
        $text =~ s/^$tag//xmsg;
    }
    write_file($outfile, $text);
    my @lines = split /\n+/, $text;
    foreach my $line (@lines) {
        $line =~ s/\s+$//;
    }
}



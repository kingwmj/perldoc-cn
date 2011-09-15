#!perl

use strict;
use warnings;
use 5.010;

use autodie;
use File::Basename qw< basename >;
use List::MoreUtils qw< uniq >;
# use Scalar::Util qw< readonly openhandle refaddr>;
# use List::Util qw< max min maxstr sum reduce first shuffle>;
# use List::MoreUtils qw< any all none notall pairwise each_array uniq>;
# use File::Find;
# use File::Basename qw< basename dirname >;
# use File::Slurp qw< read_file write_file >;
use Storable qw< store retrieve >;

# 断句模块
use Lingua::Sentence qw<>;
my $splitter = Lingua::Sentence->new("en");
#my @sentext = $splitter->split_array($podtext);

# 调试模式，设置输出句柄
my $DEBUG = 1;
if ($DEBUG) {
   open(OUT, '>', 'debug.txt');
}

# 加载字典
my $dict_all   = 'dict/dict.txt';       # 字典合并
my $dict_known = 'dict/dict_know.txt';  # 常用词字典
my $dict_study = 'dict/dict_study.txt'; # 生僻字字典
my $dict_code  = 'dict/dict_code.txt';  # 代码字典，无须翻译

# 将字典数据加载到 %dict_hash 散列中
my (%hash_dict_all, %dict_hash);
foreach my $dict ($dict_all, $dict_known, $dict_study, $dict_code) {
	open(my $fh_dict, '<', $dict);
	while (<$fh_dict>) {
		chomp;
		if ($_ =~ /\|\|/) {
			my($key, $value) = split(/\|\|/, $_);
			$dict_hash{$key} = $value;
		}
	}
}

my $blank = "\x{0020}" x 4;
my %header = (
    'AUTHOR AND COPYRIGHT' => '作者及版权',
    'AUTHOR' => '作者',
    'AVAILABILITY' => '有效性',
    'BUGS' => '待改进',
    'CAVEATS' => '注意',
    'CHANGES' => '变更',
    'COPYRIGHT AND LICENSE' => '授权协议',
    'DESCRIPTION' => '描述',
    'DIAGNOSTICS' => '错误警告',
    'EXAMPLES'   => '实例',
    'FILES'   => '文件',
    'HISTORY' => '历史',
    'NAME'    => '名称',
    'NOTES'   => '注意事项',
    'OPTIONS' => '选项',
    'SEE ALSO' => '引申阅读',
    'SYNOPSIS' => '范例',
);

my @filelist = glob("en/*.pod");

foreach my $podfile (@filelist) {
    my $filename = basename $podfile;
    my $outfile  = "temp/$filename";
	open(my $fh_in,  '<', $podfile) or die $!;
    # 输出句柄以 utf8 为编码
    open(my $fh_out, '>', $outfile) or die $!;
    say {$fh_out} "=encoding utf8\n";
    my $blank_line = 0; # 空行计数
    my @format;
    while (<$fh_in>) {
        chomp;

        # 预处理部分
        s/\s+$//;     # 去除尾部空格
        s/\t/$blank/; # 将制表符扩展为四个空格
        s/X<.*?>//g;  # 去除索引标签，以后需要翻译

        # 将连续的空行合并成一行
        $blank_line++   if     (/^$/);
        $blank_line = 0 unless (/^$/);
        next if ($blank_line > 1);

        # 提取格式化字符串信息
        # 提取 <<  >> 结构
        my @format_words = /[BLCSF]<<\s.*?\s>>/g;
        push @format, @format_words;
        uniq @format;
        # say OUT "@format_words" if (scalar @format_words > 0);
        
        # 输出单独空行
        if (/^$/) {say {$fh_out} $_; next};

        # 原样输出原文
        if (/^=over\s*\d*$/) {say {$fh_out} $_; next}; # =over 4
        if (/^=back$/)       {say {$fh_out} $_; next}; # =back
        if (/^=item\s+\*$/)  {say {$fh_out} $_; next}; # =item *
        if (/^=item\s+\d+$/) {say {$fh_out} $_; next}; # =item 8
        if (s/^\s+/$blank/)  {say {$fh_out} $_; next}; # 代码部分

        # 标题翻译
        if (/^(=head[12]|=item)\s+(.*)$/) {
            my $header = $1;
            my $text   = $2;
            if (exists $header{$2}) {
                my $tranlate = $header{$2} ;
                say {$fh_out} "$header $tranlate";
                next;
            }
            # 如果不在匹配范围内，原文输出
            say {$fh_out} $_;
            next;
        }
        say {$fh_out} "## $_";
    }
}



#!perl

use strict;
use warnings;
use 5.010;
use autodie;
use File::Basename qw< basename >;

# 预处理 C<Pod> 中的内容
# 将2个以上的空行合并成一个空行

# 调试模式，设置输出句柄
my $DEBUG = 1;
if ($DEBUG) {
   open(DEBUG, '>', 'debug.pod');
}

# 将字典数据加载到 %dict_hash 散列中
my (%dict_hash);
my $dict_code = '../dict/dict_code.txt';
foreach my $dict ($dict_code) {
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
my @filelist = glob("../en/*.pod");

foreach my $podfile (@filelist) {
    my $filename = basename $podfile;
    my $outfile  = "../precess/$filename";
	open(my $fh_in,  '<', $podfile) or die $!;
    # 输出句柄以 utf8 为编码
    open(my $fh_out, '>', $outfile) or die $!;
    say {$fh_out} "=encoding utf8\n";
    my $text = "";
    while (my $line = <$fh_in>) {
        chomp $line;
        # 预处理部分
        $line =~ s/\s+$//;      # 去除尾部空格
        $line =~ s/\t/$blank/g; # 将制表符扩展为四个空格
        if (($line =~ /^$/) or ($line =~ /^\s/)) {
            say {$fh_out} "$text\n" unless ($text =~ /^$/);
            $text = "";    
        }
        # 行内容保存起来
        $text .= $line;
    }
}

close DEBUG;

#!perl

use strict;
use warnings;
use 5.010;
use File::Find;
use File::Basename;
use Storable qw(store);

# 将标准的中英文翻译模板，转换为散列，并保存为 .sen_storable 文档

# 中英文翻译模板目录
my $temp_trans_dir = 'Transfer_sentense';
# 递归搜索目录，获取文件列表
my @filelist;
find(\&wanted, "../$temp_trans_dir");

# 搜索所有POD结尾的文档，模板是用POD格式，这样具有可读性。
sub wanted {
	if ((-T $_) && ($_ =~ m{\.pod$}i)) 
	{push @filelist, $File::Find::name;}
}

# 从源码目录开始，就保持目录结构，保证最后结果也是同样结构。
my $storable_sen_dir = 'Storable_sentense';

# 遍历搜索结果，解析模板为散列，并保存到相同结构目标目录
foreach my $file (@filelist) {
	# 替换目录名称，生成目标文件目录
	(my $out_file = $file) =~ s{$temp_trans_dir}{$storable_sen_dir};
	$out_file =~ s{\.pod$}{}; # 消除文件后缀
	$out_file .= '.sen_Storable'; # 新后缀
	my $filedir = dirname($out_file);
	mkdir $filedir unless (-e $filedir);
	my %sen_en_cn;
	my ($english_txt, $chinese_txt);
	open(my $fh_file, '<', $file) or die $!;
	while (my $line = <$fh_file>) {
		chomp $line;
		($english_txt) = $line =~ m{^=encoding\sEN\s=>(.*)$};
		($chinese_txt) = $line =~ m{^=encoding\sCN\s=>(.*)$};
		$sen_en_cn{$english_txt} = $chinese_txt;
	}
	store(\%sen_en_cn, $out_file) or die $!;
}


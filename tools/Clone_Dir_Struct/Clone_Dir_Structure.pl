#!perl

use strict;
use warnings;
use File::Find;
use File::Basename;
use File::Path qw(make_path);

# 克隆目录结构
my ($source_dir, $out_dir) = @ARGV;
$source_dir ||= 'bmp'; # 源文件夹
$out_dir ||= 'png'; # 目标文件夹
my @dirlist;
find(\&wanted, $source_dir);

# 文件夹测试是 -d
sub wanted { if (-d $_) { push @dirlist, $File::Find::name; } }

my %hash_dir;
foreach my $file (@dirlist) {
	next if ($file =~ /\./);
	my $target_dir = dirname($file);
	$target_dir =~ s/$source_dir/$out_dir/;
	my $length = $target_dir =~ s{/}{/}g;
	$hash_dir{$target_dir} = $length;
}

sub bylength { $hash_dir{$a} cmp $hash_dir{$b} };
# 建立文件夹结构
foreach my $dir (sort bylength keys %hash_dir) {
	my $length = $hash_dir{$dir};
    # 目录创建顺序如果不是递增，则会出现问题
	if (not -e $dir) {
		make_path($dir) or warn "Can not make $dir: $!";
		print "make Dir $dir\n";
	}
}
# 递归的搜索目录，获得文件
# 首先递归的清理目标文件夹中的所有文档
# 递归的在目标文件夹中创建文件夹结构
# 然后拷贝文件
# 尤其在处理模块文档的时候，尤其有用
# 提取POD，然后进行翻译。

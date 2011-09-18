#!perl
use strict;
use warnings;
use File::Find;
use File::Basename;
use 5.010;
use File::Path qw(make_path);
use File::Copy;

my $filter_dir = 'perl-5.14.0';
open(OUT, ">debug.txt") or die $!;
my @filelist;
find(\&wanted, "../$filter_dir");

# 搜索所有pm,pl结尾的文档，这些文档均可能包含POD信息。
# 将所有可能包含POD信息的文档提取出来，放置在另外一个文件夹中。
# mkdir $outputdir, 0755 or warn "Cannot make $outputdir: $!";
# if -e $filename 测试文件是否存在，对于解析pm或者pl文件的时候，
# 需要提前测试pod文档是否存在，如不存在，才创建
# 文件夹测试也是 -e $filedir
sub wanted {
	if ((-T $_) && ($_ =~ m{\.(?:pm|pod)$}i)) {
		push @filelist, $File::Find::name;
	}
}
my $out_dir = 'Perl_Pod';
my %pod_dir;
FILE:
foreach my $file (@filelist) {
	my $filedir = dirname($file);
	$filedir =~ s/$filter_dir/$out_dir/;
	my $length = $filedir =~ s{/}{/}g;
	$pod_dir{$filedir} = $length;
}

sub bylength { $pod_dir{$a} cmp $pod_dir{$b} };
# 建立文件夹结构
foreach my $dir (sort bylength keys %pod_dir) {
	my $length = $pod_dir{$dir};
	say OUT "$length => $dir";
    # 目录创建顺序如果不是递增，则会出现问题
	if (not -e $dir) {
		make_path($dir, 1, 0755) or warn "Can not make $dir: $!";
	}
}
# 拷贝pod,pm文件到文件夹
FILEPOD:
foreach my $file (@filelist) {
	if ($file ~~ m{\.(?:pod|pm)}) {
		(my $outfile = $file) =~ s/$filter_dir/$out_dir/;
		copy($file, $outfile) or die $!;
	}
}


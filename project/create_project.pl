#!perl

use strict;
use warnings;
use File::Find;
use File::Copy;

# 新建目录，初始化一些目录，新建一个字体项目
my ($project_name) = @ARGV;
$project_name ||= 'new';
mkdir $project_name;
my $sample_dir = 'sample';
my (@sample_dirlists, @sample_filelists);
print "Seaching the dir of $sample_dir\n";
find(\&finddir, $sample_dir);
sub finddir {
	if (-d $_) {
		push @sample_dirlists, $File::Find::name;
	}
}
# 遍历目录，新建目录
foreach my $dir (@sample_dirlists) {
	(my $new_dir = $dir) =~ s/sample/$project_name/;
	print "create $new_dir\n";
	mkdir $new_dir;
}

# 拷贝初始化文件到新建目录
copy("../bin/setup.pl",  "$project_name/setup.pl");
copy("../bin/setup.pl.bat", "$project_name/setup.bat");

# 命令行提示 
print "copy ../bin/setup.pl => $project_name/setup.pl\n";
print "copy ../bin/setup.bat => $project_name/setup.bat\n";

print "Running over!";

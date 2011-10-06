#!perl

use strict;
use warnings;
use autodie;
use File::Basename;
use Cwd;

# 获取当前目录
my $current_dir = getcwd();
print "Current Dir is $current_dir\n";

# 获取当前目录名
my ($project_name) = $current_dir =~ m{project/(.*?)$};
print "Project Name: $project_name\n";

# 针对新的项目新建脚本文件 01_pod_checker.bat
my $podchecker_bat = "$current_dir/01_pod_checker.bat";
print "Create $podchecker_bat ...\n";
open(my $fh_podchecker, ">", $podchecker_bat);
print $fh_podchecker <<EOF;
cd ../../bin
perl 01_pre_pod.pl $project_name
pause
EOF

print "Create the $podchecker_bat over!\n";

# 针对新的项目新建脚本文件 02_parse_pod.bat
my $parsepod_bat = "$current_dir/02_parse_pod.bat";
print "Create $parsepod_bat ...\n";
open(my $fh_parsepod, ">", $parsepod_bat);
print $fh_parsepod <<EOF;
cd ../../bin
perl 02_wrap_pod.pl $project_name
perl 03_split_pod.pl $project_name
perl 04_parse_rare_word.pl $project_name
perl 05_parse_encn_pod.pl $project_name
perl 06_tran_pod.pl $project_name
pause
EOF

print "Create the $parsepod_bat over!\n";

# 针对新的项目新建脚本文件 03_check_pod.bat
my $checkdict_bat = "$current_dir/03_check_dict.bat";
print "Create $checkdict_bat ...\n";
open(my $fh_checkdict, ">", $checkdict_bat);
print $fh_checkdict <<EOF;
cd ../../bin
perl check_dict.pl $project_name
pause
EOF

print "Create the $checkdict_bat over!\n";

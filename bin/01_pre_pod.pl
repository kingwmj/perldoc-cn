#!perl

# ------------------------------------------
# 遍历 ../en 文件夹中所有的 POD 文档，将格式
# 错误信息保存到 ../en/podcheck_result.txt
# ------------------------------------------

use strict;
use warnings;
use 5.010;
use ParseTools qw<findlist>;
use Pod::Checker;
# -----------------------------------
# 命令行处理
# -----------------------------------
my ($project_name) = @ARGV;
$project_name ||= 'sample';
my $project_dir = "../project/$project_name";
# ------------------------------------
my $checker = new Pod::Checker;
my $find_dir = "$project_dir/00_raw_txt";
my @filelist = findlist($find_dir, qr/\.pod$/);
my $outfile = "$find_dir/podcheck_result.txt";

open(my $fh, '>', $outfile);
foreach my $file (@filelist) {
    my $string;
    $checker->parse_from_file($file, $fh);
    say "Checking $file ...";
}

say "Please Look $outfile to check error";

__END__


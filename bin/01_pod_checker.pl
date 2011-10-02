#!perl

# ------------------------------------------
# 遍历 ../en 文件夹中所有的 POD 文档，将格式
# 错误信息保存到 ../en/podcheck_result.txt
# ------------------------------------------

use strict;
use warnings;
use 5.010;

use Pod::Checker;

my $checker = new Pod::Checker;
my @filelist = glob("../en/*.pod");
my $outfile = '../en/podcheck_result.txt';
open(my $fh, '>', $outfile);
foreach my $file (@filelist) {
    my $string;
    $checker->parse_from_file($file, $fh);
    say "Checking $file ...";
}

say "Please Look $outfile to check error";

__END__


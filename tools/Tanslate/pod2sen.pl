#!perl

use strict;
use warnings;
use 5.010;

# ==============脚本功能介绍===============
# 将 Pod 文件格式 转换为 Sen 文件格式
# 用于手工翻译
# =========================================

# 日期：Fri Sep  2 14:32:50 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

use File::Basename qw<basename>;
use File::Slurp qw<read_file>;
use Lingua::Sentence;

my $splitter = Lingua::Sentence->new("en");

mkdir 'sen' unless (-e 'sen');
mkdir 'pod' unless (-e 'pod');

my @filelists = glob("pod/*.pod");
foreach my $podfile (@filelists) {
    my $senfile = basename $podfile;
    $senfile =~ s/\.\w+$//; # 去除文件后缀名
    $senfile = "sen/$senfile.sen"; # 设置输出文件名
    my $podtext = read_file($podfile);
    my @sentext = $splitter->split_array($podtext);
    write_file($senfile, \@sentext) unless (-e $senfile);
}

sub write_file {
    my ($outfile, $ref_lines) = @_;
    my @lines = @{$ref_lines};
    my $count = 1;
    open (my $fh, '>', $outfile) or die $!;
    foreach my $line (@lines) {
        $line =~ s/\s+$//;
        $line =~ s/^=\w+\s+//;
        if ($line =~ /^$/) {
            say {$fh} $line;
            next;
        }
        # 输出中英文对照格式        
        say {$fh} "$count:en:\n$line";
        say {$fh} "$count:cn:\n";
        $count++;
    }
    close $fh;
}

print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


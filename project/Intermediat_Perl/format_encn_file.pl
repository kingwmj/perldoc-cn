#!perl

use strict;
use warnings;
use 5.010;
use utf8;
use autodie;
use File::Basename qw<basename>;
use File::Slurp qw<read_file write_file>;
my $blank = "\x{0020}";

# ==============脚本功能介绍===============
# 格式化 中级 Perl 的中英文对照内容 
# =========================================

open(DEBUG, '>:utf8', 'DEBUG.pod');

my $dir = 'data';
my @filelist = glob("$dir/*.pod");
foreach my $file (@filelist) {
    my $filename = basename $file;
    my $outfile = "format/$filename";
    open (my $out, '>:utf8', $outfile);
    open (my $fh, '<:utf8', $file);
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/\s+$//;
        next if ($line =~ /^$/);
        $line = delete_cn_symbol($line);
        $line =~ s/\s+/$blank/g;
        $line =~ s/\s*,\s*/,$blank/g;
        $line =~ s/\s*\.\s*/.$blank/g;
        say {$out} $line;
    }
}

sub delete_cn_symbol {
    my $text = shift;
    state $symbol = {
        '，' => ',',
        '。' => '.',
        '；' => ';',
        '“' => '"',
        '”' => '"',
        '‘' => q{'},
        '’' => q{'},
    };
    while (my ($cn, $en) = each %{$symbol}) {
        my $times = $text =~ s/$cn/$en/g;
        say DEBUG "touch $cn $times times";
    }
    return $text;
}

# ------------------------------------
# 文件运行结束标志
print "...Program Runnig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


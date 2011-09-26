#!/usr/bin/perl
# 将POD翻译成中文格式
use strict;
use warnings;
use 5.010;

my(@result_array, %dict_hash);
open(DEBUG, '>', 'debug.pod');
# dictionary file is dict_file.txt
my $dict_format = 'dict_format.txt';
my $dict_sentence = 'dict_sentence.txt';
my $dict_head = 'dict_head.txt';

# 将字典数据加载到 相应散列中
sub file2hash {
    my $filename = shift;
    my %dict_hash;
    open(my $fh_dict, '<', $filename);
	while (<$fh_dict>) {
		chomp;
		if ($_ =~ /\|\|/) {
			my($key, $value) = split(/\|\|/, $_);
			$dict_hash{$key} = $value;
		}
	}
    close $fh_dict;
    return \%dict_hash;
}

# 1 将POD解析成 sentence 结构。

my @filelist = glob("../precess/*.pod");
my @pods;
foreach my $file ( @filelist ) {
	say "Starting parse file $file ...";
    my $text = '';
	open(my $fh, '<', $file);
	while ( my $line = <$fh> ) {
        chomp $line;
        if (($line =~ /^$/) or ($line =~ /^\s/)) {
            push @pods, $text unless ($text =~ /^\s*$/);
#            say DEBUG "($text)" unless ($text =~ /^\s*$/);
            $text = "";    
        }
        # 行内容保存起来
        $text .= $line;
    }
}

use Lingua::Sentence;
my $splitter = Lingua::Sentence->new("en");
foreach my $sentence (@pods) {
    my $split = $splitter->split($sentence);
    my @split = split /\n/, $split;
    foreach my $line (@split) {
        chomp $line;
        say DEBUG "($line)";
    }
}


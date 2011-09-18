#!perl

use strict;
use warnings;
use 5.010;
use Text::Sentence qw( split_sentences );

# 此程序规格化需要翻译的句子为一句一句的格式

my @filelist = glob("*.pod");

foreach my $file (@filelist) {
	open(my $fh_file, '<', $file) or die $!;
	my $output = "$file.new";
	my $sen_flag = 0;
    my $sen_count = 0; # 设定句子数量，如果只有一行，就不使用断句功能。
	my $sentense = '';
    open(my $fh_out, '>', $output) or die $!;
	while (my $line = <$fh_file>) {
		chomp $line;

		$line =~ s/^\s+$//; # 去除空隔行
		$line =~ s/\s+$//;  # 去除行末空格
		# 对于带标识符和代码行，直接输出
        if (($line =~ /^=/) || ($line =~ /^\s+/)) {
			say $fh_out $line;
			next;
		}
		# 对于空行，直接输出
		if (($sen_flag == 0) && ($line =~ /^$/)) {
			say $fh_out $line;
			next;
		}
        # 如果第一次遇到内容行，设置句子标志为 1 
		if (($sen_flag == 0) && ($line !~ /^$/)) {
			$sen_flag = 1;
			$sentense .= $line;
			$sen_count++;
			next;
		}
		if (($sen_flag == 1) && ($line !~ /^$/)) {
			$sentense .= " $line";
			$sen_count++;
			next;
		}
		if (($sen_flag == 1) && ($line =~ /^$/)) {
			$sen_flag = 0;
			if ($sen_count == 1) {
				say $fh_out $sentense;
			}
			else {
				my @split_line = split_sentences($sentense);
				SEN:
				foreach my $sen (@split_line) {
					say $fh_out $sen;
				}
			}
			print $fh_out "\n";
			$sentense = qq{};
			$sen_count = 0;
		}
	}
}

		

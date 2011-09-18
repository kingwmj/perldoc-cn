#!perl

use warnings;
use strict;
use 5.010;
use utf8;
use File::Find;

use File::Basename;

use Encode;

# input the text file from /unknown_encode_text_file
# output the text file to /utf8_text_file
my $input_dir  = './unknown_encode_text_file';
my $output_dir = './utf8_text_file';

my @filelist;

find(\&wanted, $input_dir);
sub wanted {
	if ($_ =~ /\.(?:mod|pod|pm|pl|txt)$/i) {
		if ($File::Find::name !~ /transfered/) {
			push @filelist, $File::Find::name;
		}
	}
}

EFILE:
foreach my $file (@filelist) {
	open(FILE, $file) or die $!;
	my $filename = basename $file;
	my $out_file_gbk  = "$output_dir/gbk_$filename";
	my $out_file_utf = "$output_dir/utf8_$filename";
	open(my $fh_out_gbk, ">$out_file_gbk") or die $!;
	open(my $fh_out_utf, ">$out_file_utf") or die $!;
	PARSE:
	while (my $line = <FILE>) {
		chomp $line;

		my ($gbk_string, $utf_string) = transfer2utf($line);

		say $fh_out_gbk $gbk_string;
		say $fh_out_utf $utf_string;
	}
}

sub transfer2utf {
	my $string = shift;
	my $de_gbk_string = decode('gbk', $string);
	my $de_utf_string = decode('utf8', $string);
	my $en_gbk_string = encode('utf8', $de_gbk_string);
	my $en_utf_string = encode('utf8', $de_utf_string);
	return ($en_gbk_string, $en_utf_string);
}


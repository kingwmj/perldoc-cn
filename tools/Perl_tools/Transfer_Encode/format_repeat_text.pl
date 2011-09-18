use warnings;
use strict;
use 5.010;
use Encode;

my @filelist = glob("htm/*.txt");

my $hz_space = '';
my $hz_space1 = '　';
my $end_txt1 = '目录';
my $end_txt2 = '上章';
my $end_txt3 = '下章';

$hz_space = transfer_code($hz_space);
$hz_space1 = transfer_code($hz_space1);
$end_txt1 = transfer_code($end_txt1);
$end_txt2 = transfer_code($end_txt2);
$end_txt3 = transfer_code($end_txt3);
EFILE:
foreach my $file (@filelist) {
	open(FILE, $file) or die $!;
	(my $out_file = $file) =~ s/txt/TXT/;
	open(OUT, ">$out_file") or die $!;
	PARSE:
	while (my $line = <FILE>) {
		chomp $line;
#		next PARSE if ($line =~ /$end_txt2/);
		$line =~ s{$hz_space}{ }g;
		$line =~ s{$hz_space1}( )g;
		$line =~ s{\s+}{ }g;
		$line =~ s{^\s|\s$}{}g;
		next PARSE if ($line =~ /^$end_txt1/);
		next PARSE if ($line =~ /^$end_txt2/);
		next PARSE if ($line =~ /^$end_txt3/);
		next PARSE if ($line =~ /^\s*$/);
		if ($line =~ m/^(.*?)\s+(.*?)/) {
			my @words = split /\s+/, $line; # 1 2 1 2
			my $length = scalar(@words); # 4
			my $count = $length / 2; # 2
			NUMBER:
			for my $id (0..($count-1)) {
				my $endid = $id - $count;
				last NUMBER if ($words[$id] ne $words[$endid]);
				$line = "@words[0..$count-1]";
			}
		}
		say OUT "$line\n";
	}
}

sub transfer_code {
	my $string = shift;
	$string = decode('utf8', $string);
	$string = encode('gbk', $string);
	return $string;
}


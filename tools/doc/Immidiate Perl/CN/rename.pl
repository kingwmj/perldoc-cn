use strict;
use warnings;
use File::Basename qw<basename>;
use File::Copy qw<copy>;

my @filelist = glob("*.pod");

for my $file (@filelist) {
    my $filename = basename $file;
    my ($chapter, $section) = $file =~ /(\d+)-(\d+)/;
    $chapter = "0$chapter" if ($chapter < 10);
    $section = "0$section" if ($section < 10);
    my $newfilename = "Intermediate_Perl_${chapter}_$section.pod";
    copy($file, $newfilename);
}


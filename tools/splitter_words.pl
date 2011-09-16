#!perl

use strict;
use warnings;
use 5.010;

use Lingua::EN::Splitter qw( words paragraphs );
use Lingua::EN::Sentence qw( get_sentences );

my $text = <<EOT;
Lingua::EN::Splitter is a useful module that allows text to be split up 
into words, paragraphs, segments, and tiles.

Paragraphs are by default indicated by blank lines. Known segment breaks are
indicated by a line with only the word "segment_break" in it.

segment_break

This      module does not make any attempt to guess segment boundaries. For that,
see L<Lingua::EN::Segmenter::TextTiling>.

EOT

my $words = words($text);
my $paragraphs = paragraphs($text);
my $sentences  = get_sentences($text);

#foreach ( @{$words} )            { say }
sub output {
    my $ref_array = shift;
    my $count = 1;
    foreach my $element (@{$ref_array}) {
        say "$count $element";
        $count++;
    }
}

foreach my $paragraph ( @{$paragraphs} )  {
    my $sentences = get_sentences($paragraph);
    output($sentences);
}


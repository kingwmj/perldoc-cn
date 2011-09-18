#!/usr/bin/env perl

# podtags - create a tags file for POD, for use by vi(m)
# 在head行上设置标签 X<> 格式中包含的字符串就是可以跳转的标签
use strict;
use utf8;
use warnings;

# Global variables
my $VERSION = "2.21";	# pltags version
my @tags = ();		# List of produced tags

# Create a tag file line and push it on the list of found tags
sub MakeTag($$$$$) {
    my ($tag,		# Tag name
	$type,		# Type of tag
	$is_static,	# Is this a static tag?
	$file,		# File in which tag appears
	$line) = @_;	# Line in which tag appears

    my $tagline = "";   # Created tag line

    # Only process tag if not empty
    if ($tag) {
		# Get rid of \n, and escape / and \ in line
		chomp $line;
		$line =~ s/\\/\\\\/g;
		$line =~ s/\//\\\//g;

		# Create a tag line
		$tagline = "$tag\t$file\t/^$line\$/";

		# Push it on the stack
		push (@tags, $tagline);
   	}
}


# Parse all X<.*?> tags names from statement
sub Podtags($) {
    my ($stmt) = @_;
    my @vars;
    # Remove my or local from statement, if present
    if ($stmt =~ /^=head(1|2|3|4)\s+/) {
		@vars = ($stmt =~ /X<(.*?)>/g);
	}
    return (@vars);
}

############### Start ###############

print "\npodtags $VERSION by Song Zhiquan <songzan\@foxmail.com>\n\n";

# Usage if error in options or no arguments given
unless (@ARGV) {
    print "  Usage: $0 filename ...\n\n";
    print "  Example: $0 *.pl *.pm ../shared/*.pm\n\n";
    exit;
}

# Loop through files on command line - 'glob' any wildcards, since Windows
# doesn't do this for us
foreach my $file ( map { glob } @ARGV )
{
    # Skip if this is not a file we can open.  Also skip tags files and backup
    # files
    next unless ((-f $file) && (-r $file) && ($file !~ /tags$/)
		 && ($file !~ /~$/));

    print "Tagging file $file...\n";

    open (IN, $file) or die "Can't open file '$file': $!";

    # Loop through file
    foreach my $line (<IN>) {
		if ($line =~ /^=head.*?X<.*?>/) {
			my @xtags = Podtags($line);
			# Loop through all tags names in line
			foreach my $tag (@xtags)  {
			    MakeTag($tag, "v", 1, $file, $line);
		    }
		}
    }
    close (IN);
}

# Do we have any tags?  If so, write them to the tags file
if ( @tags )
{
    # Add some tag file extensions if we're told to
	push (@tags, "!_TAG_FILE_FORMAT\t2\t/extended format/");
	push (@tags, "!_TAG_FILE_SORTED\t1\t/0=unsorted, 1=sorted/");
	push (@tags, "!_TAG_PROGRAM_AUTHOR\tSong Zhiquan\t/songzan\@foxmail.com/");
	push (@tags, "!_TAG_PROGRAM_NAME\tpodtags\t//");
	push (@tags, "!_TAG_PROGRAM_VERSION\t$VERSION\t/supports multiple tags and extended format/");

    print "\nWriting tags file.\n";

    open (OUT, ">tags") or die "Can't open tags file: $!";

    foreach my $tagline (sort @tags) {
		print OUT "$tagline\n";
    }
    close (OUT);
}
else {
    print "\nNo tags found.\n";
}

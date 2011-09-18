#!perl

use strict;
use warnings;
use 5.014;

use File::Copy;

# ==============脚本功能介绍===============
# 将 POD 文件归类的脚本
# =========================================

# 日期：Wed Aug 31 14:07:41 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

# move file to dir
my @Overview  = qw<perl perlintro perltoc>;
movefile('Overview', @Overview);

my @Tutorials = qw<
perlreftut perldsc perllol perlrequick perlretut
perlboot perltoot perltooc perlbot perlperf 
perlstyle perlcheat perltrap
perldebtut perlfaq perlfaq1 perlfaq2 perlfaq3
perlfaq4 perlfaq5 perlfaq6 perlfaq7 perlfaq8
perlfaq9
>; 

movefile('Tutorials', @Tutorials);

my @Reference_Manual = qw<
perlsyn perldata perlop perlsub perlfunc perlopentut
perlpacktut
perlpod perlpodspec perlpodstyle
perlrun perldiag perllexwarn 
perldebug perlvar perlre perlrebackslash
perlrecharclass perlreref perlref 
perlform perlobj perltie perldbmfilter
perlipc perlfork perlnumber perlthrtut 
perlport perllocale perluniintro
perlunicode perlunifaq perluniprops
perlunitut perlebcdic perlsec perlmod perlmodlib perlmodstyle
perlmodinstall
perlnewmod perlpragma perlutil perlcompile perlfilter perlglossary
>;
movefile('Reference_Manual', @Reference_Manual);

my @Internals_and_C_Language_Interface = qw<
perlembed perldebguts perlxstut perlxs perlclib perlguts perlcall perlmroapi perlreapi perlreguts perlapi perlintern perliol perlapio perlhack perlsource perlinterp perlhacktut perlhacktips perlpolicy perlgit 
>;
movefile('Internals_and_C_Language_Interface',
    @Internals_and_C_Language_Interface);
my @Miscellaneous = qw<
perlbook perlcommunity perltodo 
perldoc perlhist perldelta 
perlartistic perlgpl
>;
movefile('Miscellaneous', @Miscellaneous);
my @Language_Specific = qw<perlcn perljp perlko perltw>;
my @Platform_Specific = qw<perlwin32>; 

sub movefile {
    my ($dir, @filenames) = @_;
    foreach my $file (@filenames) {
        my $filename = "$file.pod";
        mkdir $dir unless (-e $dir);
        my $targetfile = "$dir/$filename";
        mv($filename, $targetfile);
        say "$filename => $targetfile";
    }
    return 1;
}

movefile('Platform_Specific', @Platform_Specific);
movefile('Language_Specific', @Language_Specific);

print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


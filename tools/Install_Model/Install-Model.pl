#!perl

use strict;
use warnings;
use 5.014;

# 推荐的核心模块
use base;
use Benchmark;
use Carp;
use Charnames;
use CPAN;
use Data::Dumper;
#use Devel::DProf;
use English;
use Fatal;
use File::Glob;
use File::Temp;
use Getopt::Long;
use IO::File;
use IO::Handle;
use List::Util;
use Memoize;
use overload;
use Scalar::Util;
use Test::Harness;
use Test::More;
use Test::Simple;
use Time::HiRes;
use version;

# 推荐的CPAN模块
use Attribute::Types;
use Class::Std;
use Class::Std::Utils;
use Config::General;
use Config::Std;
use Config::Tiny;
use Contextual::Return;
use Data::ALias;
use DateTime;
use DBI;
use Devel::Size;
use Exception::Class;
use File::Slurp;
use Fileter::Macro;
use Getopt::Clade;
use Getopt::Euclid;
use HTML::mason;
use Inline;
use IO::InSitu;
use IO::Interactive;
use IO::Prompt;
use Lexical::Alias;
use List::MoreUtils;
use Log::Stdlog;
use Module::Build;
use Module::Starter;
use PBP;
use Parse::RecDescent;
use Perl6::Builting;
use Perl6::Export::Attrs;
use Perl6::Form;
use Perl6::Slurp;
use POE;
use Readonly;
use Regexp::Autoflags;
use Regexp::Assemble;
use Regexp::Common;
use Regexp::MatchContext;
use Smart::Comments;
use Sort::Maker;
use Sub::Installer;
use Text::Autoformat;
use Text::CSV;
use Text::CSV::Simple;
use Text::CSV_XS;
use XML::Parser;
use YAML;

# ==============脚本功能介绍===============
#  
# =========================================

# 日期：Wed Aug 31 09:59:04 2011
# 作者: 宋志泉 songzhiquan@hotmail.com


print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


package ParseTools;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw<>;
our @EXPORT_OK=qw<dict2hash hash2dict array2hash array2file findlist
                  split2sentence filter_format_str filter_ignore_str
                  clean_dir>;
our @VERSION = 1.00;

use strict;
use warnings;
use 5.010;
use autodie;
use File::Slurp qw<read_file write_file>;
use List::MoreUtils qw<mesh uniq>;
use Lingua::Sentence;
use Regexp::Common qw/URI/;
use File::Find qw<find>;
use Carp qw(carp croak);
use File::Path qw<make_path remove_tree>;


# 清理指定目录，删除所有文件和子目录
sub clean_dir {
    my $dir = shift;
    remove_tree($dir, 1);
    make_path($dir);
    return 1;
}

# 获取指定目录的所有子目录的文件目录
# findlist($dir,qr/\.pod$/);
sub find_by_regex
	{
	require File::Spec::Functions;
	require Carp;
	require UNIVERSAL;
	
	my $regex = shift;
	
	unless( UNIVERSAL::isa( $regex, ref qr// ) )
		{
		croak "Argument must be a regular expression";
		}
		
	my @files = ();
	
	sub { push @files, 
		File::Spec::Functions::canonpath( $File::Find::name ) if m/$regex/ },
	sub { wantarray ? @files : [ @files ] }
}

sub findlist {
    my ($dir, $regex) = @_;
    my ($wanted, $reporter) = find_by_regex($regex);
    find($wanted, $dir);
    my @filelist = $reporter->();
    return ( wantarray ? @filelist : [@filelist]);
}

# 字典转换成散列 my $ref_dict_hash = dict2hash($file1, $file2);
sub dict2hash {
    my @filelist = @_;
    my %dict_hash;
    foreach my $file (@filelist) {
        my @lines = read_file($file, binmode => ':utf8');
        foreach my $line (@lines) {
            chomp $line;
            $line =~ s/\r//;
            if ($line =~ /\|\|/) {
                my ($key, $value) = split /\|\|/, $line;
                $key = lc $key; # 全部以小写形式保存字典
                $dict_hash{$key} = $value;
            }
        }
    }
    return (wantarray ? %dict_hash : \%dict_hash);
}

# 将字符串数组转换成映射字符散列
sub array2hash {
    my $ref_array = shift;
    my @array = uniq @{$ref_array};
    my $number = scalar @array;
    my @conceal = map { sprintf("&&%0.4x", $_) } (1 .. $number);
    # 合并两个数据类型相同的数组
    my %array2hash = mesh @array, @conceal;
    return (wantarray ? %array2hash : {%array2hash});
}

# 将一个数组拆分成按照句子的数组
sub split2sentence {
    my @array = @_;
    my $splitter = Lingua::Sentence->new("en");
    my @split = map { $splitter->split_array($_) } @array;
    return (wantarray ? @split : [@split]);
}

# 将散列保存为字典文件 hash2dict(\%hash, $dict_name);
sub hash2dict {
    my ($ref_hash, $filename) = @_;
    my %dict_hash = %{$ref_hash};
    my $text;
    foreach my $key (sort keys %dict_hash) {
        my $value = $dict_hash{$key};
        $text .= "$key||$value\n";
    }
    write_file($filename, { binmode => ':utf8' }, $text);
    return 1;
}

# 数组写到文件，每行之间空一行
sub array2file {
    my ($ref_array, $file) = @_;
    my @array = @{$ref_array};
    my $last_line = '';
    open (my $fh_array2file, '>', $file);
    foreach my $line (@array) {
        chomp $line;
        # 如果是代码行，则不需要插入空行
        say {$fh_array2file} $line;
        say {$fh_array2file} "\n" unless ($last_line =~ /^\s+/);
        $last_line = $line;
    }
    close $fh_array2file;
    return 1;
}

# 将Pod文档中的 head code 提取成数组
sub filter_format_str {
    my $file  = shift;
    my $text  = read_file $file;
    my @lines = read_file $file;
    # 获取 =head =over =item 等结构数组
    my @head = $text =~ /^=[a-zA-Z0-9]+\s*[^a-zA-Z\n]*/xmsg;

    # 获取每行前有空格的代码原文格式数组
    my @code = grep { chomp; /^\s{1,}/ } @lines;
    # 替换掉注释
    foreach my $element (@code) {
        # 前面必须有空格
#        $element =~ s/\s#.*//;
    }

   my @return_array = (@head, @code);
   return (wantarray ? @return_array : [@return_array]);
}

# 将Pod文档中的 format email func http ftp file fomat 提取成数组
sub filter_ignore_str {
    my $file  = shift;
    my $text  = read_file $file;
    my @lines = read_file $file;
    # 获取 =head =over =item 等结构数组
    my @var   = $text =~ /\b[\$@%]\w+/g;
    my @email = $text =~ /\w+@[a-zA-Z0-9_\-.]+/xmsg;
#    my @email = $text =~ /$RE{Email}{Address}/xmsg;
    my @func =  $text =~ /\w+\(\w*\)/g;
    my @http =  $text =~ /$RE{URI}{HTTP}/xmsg;
    my @ftp  =  $text =~ /$RE{URI}{FTP}/xmsg;
    my @file =  $text =~ /\b\w+\.\w+\b/xmsg;

    # 中间替换变量
    my $elt = "\x{2264}"; # E<lt> => $elt
    my $egt = "\x{2265}"; # E<gt> => $egt
    my $lt  = "\x{226e}"; # '<' => $lt 
    my $gt  = "\x{226f}"; # '>' => $gt
    my @double_format = $text =~ /[BCFILSX]<<+\s.*?\s>>+/mg;

    # 先将文本中的转义字符串替换掉
    $text =~ s/E<lt>/$elt/g;
    $text =~ s/E<gt>/$egt/g;
    my @format;
    while (1) {
        my @array = $text =~ /[BCFILSX]<[^<>]+>/mg;
        last if (scalar @array == 0);
        $text =~ s/([BCFILSX])<([^<>]+)>/$1$lt$2$gt/mg;
        push @format, @array;
    }
    # 恢复替换结果
    @format = (@double_format, @format);
    uniq @format;
    foreach (@format) {
       s/$elt/E<lt>/g;
       s/$egt/E<gt>/g;
       s/$lt/</g;
       s/$gt/>/g;
       s/\n/ /g;
   }
   my @return_array = (@var, @email, @http, @ftp, @func, @file, @format);
#   my @return_array = (@email);
   return (wantarray ? @return_array : [@return_array]);
}

1;

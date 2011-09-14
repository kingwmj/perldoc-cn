#!perl

use strict;
use warnings;
use 5.010;

use File::Basename qw< basename >;

my %header = (
    'AUTHOR AND COPYRIGHT' => '作者及版权',
    'AUTHOR' => '作者',
    'AVAILABILITY' => '有效性',
    'BUGS' => '待改进',
    'CAVEATS' => '注意',
    'CHANGES' => '变更',
    'COPYRIGHT AND LICENSE' => '授权协议',
    'DESCRIPTION' => '描述',
    'DIAGNOSTICS' => '错误警告',
    'EXAMPLES'   => '实例',
    'FILES' => '文件',
    'HISTORY' => '历史',
    'NAME'   => '名称',
    'NOTES' => '注意事项',
    'OPTIONS' => '选项',
    'SEE ALSO' => '引申阅读',
    'SYNOPSIS' => '范例',
);

my @filelist = glob("en/*.pod");

foreach my $podfile (@filelist) {
    my $filename = basename $podfile;
    my $outfile  = "temp/$filename";
	open(my $fh_in,  '<', $podfile) or die $!;
    # 输出句柄以 utf8 为编码
    open(my $fh_out, '>', $outfile) or die $!;
    say {$fh_out} "=encoding utf8\n";

    while (my $line = <$fh_in>) {
        chomp $line;
        # 预处理部分
        $line =~ s/\s+$//; # 去除尾部空格
        # 原样输出英文
        say {$fh_out} $line;

        # 忽略行
        next if ($line =~ /^=over/);
        next if ($line =~ /^=back/);
        next if ($line =~ /^=item\s+\*/);

        # 标题翻译
        if ($line =~ /^(=head[12]|=item)\s+(.*)$/) {
            my $header = $1;
            my $text   = $2;
            if (exists $header{$2}) {
                my $tranlate = $header{$2} ;
                say {$fh_out} "$header $tranlate";
                next;
            }
        }
    }
}

        







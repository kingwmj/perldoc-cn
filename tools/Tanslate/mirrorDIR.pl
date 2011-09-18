#!perl
# ==============脚本功能介绍===============
# 对一个文件夹进行文件镜像 保存最后更新日期
# 似乎可以做一个版本管理方面的工具。 
# =========================================
# 日期：Fri Sep  2 17:13:13 2011
# 作者: 宋志泉 songzhiquan@hotmail.com

use strict;
use warnings;
use 5.010;

use File::Find;
use Storable qw< store retrieve >;
my $dirname = 'storable';
mkdir $dirname unless ( -e $dirname );

my (%filelist, %config);
# 获取当前目录文件信息
find(\&wanted, $dirname);
for my $file (keys %filelist) {
    say "$file => $filelist{$file}";
}

my $config_file = 'filelist.config';
if (-e $config_file) {
    retrieve(%config, $config_file);
    say "retrieve $config_file";
}
else {
    store(\%filelist, $config_file);
    say "Establish Config file first time";
    exit;
}

# 对比散列
my @updatelist;  # 需要更新的文件
if (%config ~~ %filelist) {
    say "File is newest";
    exit;
}
else {
    # 重新保存配置文件
    store(\%filelist, $config_file);
    # 将更新的文件列表提取出来
    FOREACH:
    foreach my $file (keys %filelist) {
        my $newtime = $filelist{$file};
        if (exists $config{$file}) {
            my $oldtime = $config{$file};
            next FOREACH if ($newtime == $oldtime);
            push @updatelist, $file;
            say "update $file";
            next FOREACH;
        }
        push @updatelist, $file;
        say "Add new file $file";
    }
}

foreach my $update (@updatelist) {
#    say "update file : $update";
}

# 递归搜索目录子程序
sub wanted {
    if ((-f $_ )) { ## && ($_ =~ /stable$/)) {
        my $mtime = (stat($_))[9];
        $filelist{$File::Find::name} = $mtime;
    }
}


print "...Runinig Over...\n";
# vim:tw=78:ts=8:ft=perl:norl:


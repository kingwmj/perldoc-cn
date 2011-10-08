#!perl

use strict;
use warnings;
use 5.010;
use autodie;
use File::Basename qw<basename>;
use ParseTools qw<findlist clean_dir>;

# ------------------------------------------
# 预处理 ../01_pre_pod 文件夹中 .pod 的内容
# 1. 去除行尾的空格
# 2. 将标题 =head 和标题之间的空格规范成一个
# 3. 将制表符替换成4个空格
# 4. 可测试各种正则表达式匹配结果
# 5. 将一个段落的断行符去掉，成为一个整行
# 6. 每个段落中间至少设置一个空行
# 输出同名 .pod 文档到 ../02_wrap_pod 目录
# ------------------------------------------

# -----------------------------------
# 命令行处理
# -----------------------------------
my ($project_name) = @ARGV;
$project_name ||= 'sample';
my $project_dir = "../project/$project_name";
# ------------------------------------

# 调试模式，设置输出句柄
open(DEBUG, '>', 'debug.pod');

# 显式定义空格和制表符
my $blank = "\x{0020}";
my $tab = $blank x 4;

# 以流格式打开所有POD文件进行预处理
my $in_dir  = "$project_dir/01_pre_pod";
my $out_dir = "$project_dir/02_wrap_pod";
my @podlist = findlist($in_dir,  qr/\.pod$/);
my @outlist = findlist($out_dir, qr/\.pod$/);
# 清理输出目录
clean_dir($out_dir) or warn "could not clean $out_dir";

# 遍历文件
foreach my $podfile (@podlist) {
    my $filename = basename $podfile;
    my $outfile  = "$out_dir/$filename";
    say "Format $podfile ......";
	open(my $fh_in,  '<', $podfile);
    # 输出句柄以 utf8 为编码
    open(my $fh_out, '>', $outfile);

    my $text = "";
    while (my $line = <$fh_in>) {
        chomp $line;

        # 预处理部分
        $line =~ s/\s+$//;      # 去除尾部空格
        $line =~ s/(=\w+)\s+/$1$blank/; # 标记语言后保留一个空格
        $line =~ s/\t/$tab/g;     # 将所有制表符替换成四个空格
        $line =~ s/\s*,\s*/,$blank/g; # 规范逗号
        $line =~ s/\s*\.\s*/.$blank/g; # 规范句号

        # 提取标题后的单词
        say DEBUG $1 if ($line =~ /(\w+\(\w*\))/); # 测试正则匹配

        # 如果代码为空行，则输出空行后重置$text
        if ($line =~ /^$/) {
            say {$fh_out} "$text\n";
            $text = "";
            next;
        }
        # 如果以代码格式开始，原样输出非空行
        if ($line =~ /^\s/) {
            say {$fh_out} $text;
            $text = "";
        }
        # 行内容保存起来
        $text .= "$line ";
    }
}

close DEBUG;

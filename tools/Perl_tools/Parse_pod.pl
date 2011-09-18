#!perl

use strict;
use warnings;
use 5.010;
use Text::Sentence qw( split_sentences );

open(DEBUG , ">debug.txt") or die $!;

# 经过段落格式化后，这次将分离需要翻译的部分，生成
# 一个翻译散列，而且，返回这个散列的查询值，将
# 查询值和另外的数据结构恢复原来的文件
# 同时处理两个结构相同的POD，先分离需要翻译的文档
# 后期，根据这个文档生成相应的中文POD
my @filelist = glob("*.new");
my @header = qw(
    head1 head2 head3 head4 pod cut over 
	back item for begin end encoding
);

my %header_regexp;
foreach my $key (@header) {
	my $value = qr/^=$key/;
	$header_regexp{$key} = $value;
}


foreach my $file (@filelist) {
	open(my $fh_file, '<', $file) or die $!;
	$. = 0; # 行号初始化
	## 合并句子后，按照行号建立散列，按照标识符建立翻译标识散列
	## 根据以上两个散列建立，翻译列表，进行数据库查询
	## 对于注释部分的翻译，如何返回原始状态
	## 行号->整行内容->前面过滤的内容->需翻译内容->后边过滤的内容
	# %all_line 行号=>行内容
	# %trans_line 行号=>需要翻译的内容
	my (%all_line, %trans_line);

	LINE:
	while (my $line = <$fh_file>) {
		chomp $line;
		$line =~ s/\s+$//;
		my $org_line = $line;
		$all_line{$.} = $org_line; # 保存原始内容

		next LINE if ($line =~ /^$/); # 跳过空行
		# 如果是以格式标识符开始，标识符以后的字符为需翻译的内容
		# 如果标识符不符合规则，报警。
		if ($line =~ m{^=(\w+)}) {
			my $header = $1;
			if (exists $header_regexp{$header}) {
				my $header_exp = $header_regexp{$header};
				$line =~ s{$header_exp\s*}{};
				# 如果完全是特殊标志或空行，就跳过
				if (($line =~ /^$/) || ($line =~ m{^[BILC]<.*>$})) {
					next LINE;
				}
				$trans_line{$.} = $line; # 保存标识符内容
			}
			else {
				say "error header character found $header";
			}
			next LINE;
		}
		if ($line =~ m{^\S}) { 
			# 如果不是以标识符或空格开头，将进入句子,需翻译
			# 但如果其中是类似引用或者特殊关键字结构，则跳过
			if ($line =~ m{^[BILC]<.*>$}) {
				say DEBUG $line;
				next LINE;
			}
			$trans_line{$.}= $line;
			next LINE;
		}
		# 如果行以空格开头, 并且是非空行，属于代码部分
		# 但是代码中的注释，需要提取出来进行翻译
		if ($line =~ m{^\s+}) {
			if ($line =~ m{^.*?#+(.*)}) {
				my $comment = $1;
				$trans_line{$.} = $comment;
			}
		}
	}
	open(my $fh_out, '>', "$file.pod") or die $!;
	foreach my $id (sort bynumber keys %trans_line) {
		say $fh_out "=encoding EN =>$trans_line{$id}\n=encoding CN =>";
	}
}

sub bynumber { $a <=> $b };

# author: jiangyujie
use utf8;
use Encode;
use URI::Escape;

$\ = "\n";

# from Unicode get utf8 decode
$str = '%u6536';
$str =~ s/\%u([0-9a-fA-F]{4}/pack("U", hex($1))/eg;
$str = encode("utf8", $str);
print uc unpack( "H*", $str);

# from Unicode get gb2312 decode
$str = '%u6536';
$str =~ s/\%([0-9a-fA-F]{4})/pack("U", hex($1))/eg;
$str = encode("gb2312", $str);
print uc unpack( "H*", $str);

# From Chinese get utf8 decode
$str = "收";
print uri_escape($str);

# From utf8 decode get chinese
$utf8_str = uir_escape("收");
print uri_unescape($str);

# from chinese get perl unicode
utf8::decode($str);
@chars = split //, $str;
foreach (@chars) {
	printf "%x ", ord($_);
}

# from chinese get standard unicode
$a = "汉语";
$a = decode("utf8", $a);
map { print "\\u", sprintf( "%x", $_) } unpack("U*", $a);

# 从标准unicode得到中文   
$str = '%u6536';   
$str =~ s/\%u([0-9a-fA-F]{4})/pack("U",hex($1))/eg;   
$str = encode( "utf8", $str );   
print $str;   
  
# 从perl unicode得到中文   
my $unicode = "\x{505c}\x{8f66}";   
print encode( "utf8", $unicode );  


use strict;
use warnings;
use Cache::FileCache;

my $fc = Cache::FileCache->new({
	'cache_root' => "/tmp/tan_session_cache",
	'namespace' => ''
});

my $sid = $ARGV[0];
if ( !$sid ){
	print "no session_id\n";
	exit(1);
}

foreach my $key ( ('session','expires') ){
	$fc->remove("${key}:${sid}");
}

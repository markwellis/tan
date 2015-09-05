#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw/:standard/;

print header(
    -status  => '503 Service Unavailable',
    -type    => 'text/html',
    -charset => 'utf-8',
    -expires => '+10s',
);

print <DATA>;

__DATA__
<!DOCTYPE html>
<html>
<head>
<title>TAN - be back soon</title>
</head>
<body>
upgrades in progress, be back soon<br />
in the meantime, here's some chat<br />
<iframe width="100%" scrolling="no" height="400" src="https://widget.mibbit.com/?server=irc.mibbit.com%3A%2B6697&amp;chatOutputShowTimes=true&amp;autoConnect=true&amp;channel=%23thisaintnews&amp;settings=8a8a5ac18a22e7eecd04026233c3df93&amp;nick=n00b" style="border:0"></iframe>
</body>
</html>

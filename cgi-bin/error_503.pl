#!/usr/bin/env perl
use strict;
use warnings;

use CGI qw/-standard/;

use Email::Sender::Simple qw/sendmail/;
use Email::Simple;
use Email::Simple::Creator;
use Sys::Hostname;

my $body = << "ENDBODY";
url:
    @{[ $q->url( -full => 1, -query =>1 ) ]}
request type:
    $ENV{REQUEST_METHOD}
client ip:
    $ENV{REMOTE_ADDR}
ENDBODY

my $email = Email::Simple->create(
  header => [
    To      => 'webmaster@thisaintnews.com',
    From    => "apache@" . hostname,
    Subject => "proxy timeout error",
  ],
  body => $body,
);

sendmail($email);

print header(
    -status  => '503 Service Unavailable',
    -type    => 'text/html',
    -charset => 'utf-8',
    -expires => '+20s',
);

print <DATA>;

__DATA__
<html>
<head>
<title>Service unavailble</title>
</head>
<body>
<h1>Sorry</h1>
<p>Something has gone wrong, but we've alerted the people in charge, and it should be fixed shortly</p>
</body>
</html>

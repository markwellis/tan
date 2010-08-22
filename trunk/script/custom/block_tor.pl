#!/usr/bin/perl

use Net::Tor::Servers;
 
my $torsrv = new Net::Tor::Servers;
my @servers = $torsrv->getservers;

print "found " . $#servers . "\n";

if ($#servers){
    print "clearing BLOCKED_TOR chain...\n";
    `iptables -F BLOCKED_TOR`;
    print "chain cleared... adding new ips\n";
    foreach my $server (@servers){
        my $cmd = "iptables -A BLOCKED_TOR -s " . $server->[0] . " -j DROP\n";
        `$cmd`;
    }
}

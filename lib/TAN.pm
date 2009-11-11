package TAN;

use strict;
use warnings;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/ConfigLoader
                Unicode
                Authentication
                Cache::FastMmap
                Session
                Session::Store::FastMmap
                Session::State::Cookie
                PageCache
            /;
our $VERSION = '0.90';
use Time::HiRes qw/time/;
use POSIX qw/floor/;

# Configure the application.
#
# Note that settings in tan.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name => 'TAN', 
    'Plugin::ConfigLoader' => {
        driver => {
            'General' => { -InterPolateVars => 1 }
        }
    },
    'Plugin::PageCache' => {
        cache_hook => 'check_cache',
        key_maker => sub {
            my $c = shift;
            return $c->req->path . $c->nsfw;
        }
    }
 );

# Start the application
__PACKAGE__->setup();

sub check_cache{
    my $c = shift;

# don't commit this!!!
return 0;
# end

# this is a hack so people who have messages dont hit the page cache
# its here coz it no worko in the end/render
    $c->stash->{'messages'} = $c->flash->{'message'};

    if ( $c->user_exists || defined($c->stash->{'no_page_cache'}) || defined($c->stash->{'messages'}) ) {
        return 0;
    }
    return 1;
}

sub nsfw{
    my ($c, $value) = @_;
    
    if (defined($value)){
        $c->session->{'nsfw'} = $value
    }
    
    if (defined($c->session->{'nsfw'}) && $c->session->{'nsfw'} == 1){
        return 1;
    }
    
    return 0;
}

sub date_ago{
    my ($c, $date) = @_;

    my $blocks = [
        {
            'name' => 'year',
            'amount' => 60*60*24*365,
        },
        {
            'name' => 'month',
            'amount' => 60*60*24*31
        },
        {
            'name' => 'day',
            'amount' => 60*60*24,
        },
        {
            'name' => 'hour',
            'amount' => 60*60,
        },
        {
            'name' => 'minute',
            'amount' => 60,
        },
        {
            'name' => 'second',
            'amount' => 1,
        },
    ];
   
    my $diff = abs( $date - time );
   
    my $i = 0;
    my @result;

    foreach my $block (@{$blocks}) {
        if ($i > 1) {
            last;
        }
        if ($diff/$block->{'amount'} >= 1) {
            ++$i;
            my $amount = floor($diff/$block->{'amount'});
            
            my $plural = ($amount>1) ? 's' : '';
            push(@result, "${amount} " . $block->{'name'} . $plural);
            $diff -= $amount*$block->{'amount'};
        }
    }
    return join(' ',@result);
}
=head1 NAME

TAN - Catalyst based application

=head1 SYNOPSIS

    script/tan_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<TAN::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

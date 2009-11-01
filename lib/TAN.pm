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
                PageCache
                Session
                Session::Store::FastMmap
                Session::State::Cookie
            /;
our $VERSION = '0.90';



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
        cache_hook => 'check_cache'
    }
 );

# Start the application
__PACKAGE__->setup();

sub check_cache{
    my $c = shift;

    if ( $c->user_exists) {
        return 0; # Don't cache
    }
    return 1; # Cache
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

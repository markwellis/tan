package TAN;

use strict;
use warnings;

use Catalyst::Runtime 5.80;
use Number::Format;
use Data::Dumper;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

=head1 NAME

TAN

=head1 DESCRIPTION

Main catalyst application

=head1 METHODS

=cut
use parent qw/Catalyst/;
use Catalyst qw/ConfigLoader
                Unicode::Encoding
                Authentication
                Cache::FastMmap
                Session
                Email
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

=head2 check_cache

B<@args = undef>

=over

doesn't cache if user is logged in

doesn't cache if user has a flash message

=back

=cut
sub check_cache{
    my $c = shift;

# this is a hack so people who have messages dont hit the page cache
# its here coz it no worko in the end/render
    $c->stash->{'message'} = $c->flash->{'message'};

# don't commit this!!!
return 0;
# end

    if ( $c->user_exists || defined($c->stash->{'no_page_cache'}) || defined($c->stash->{'message'}) ) {
        return 0;
    }
    return 1;
}

=head2 nsfw

B<@args = ($value)>

=over

returns the current nsfw value (filter is B<OFF> if 1)

sets the nsfw to value

=back

=cut
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

=head2 date_ago

B<@args = ($date)>

=over

returns how long aog a unix date was in the format x days x hours etc

=back

=cut
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

=head2 recent_comments

B<@args = undef>

=over

returns the 20 most recent comments

=back

=cut
sub recent_comments{
    my $c = shift;

    return $c->model('MySQL::Comments')->recent_comments->all;
}

=head2 filesize_h

B<@args = ($size)>

=over

takes a size (KB) and converts it to a human readable format

=back

=cut
sub filesize_h{
    my ($c, $size) = @_;

    if ( !$size ){
        return 0;
    }

    if ( $size > 1024 ){
        return Number::Format::format_number(($size / 1024)) . 'MB';
    } else {
        return Number::Format::format_number($size) . 'KB';
    }
}

=head2 url_tile

B<@args = ($title)>

=over

makes a title url/seo safe

=back

=cut
my $url_title = qr/\W+/;
sub url_title{
    my ($c, $title) = @_;

    $title =~ s/$url_title/-/ig;

    return $title;
}

=head2 finalize_error

B<@args = undef>

=over

handles catalyst 500 errors

sends email to tan.webmaster@thisaintnews.com if not in debug mode

=back

=cut
sub finalize_error {
    my ($c) = @_;

    if ( $c->debug ) {
        $c->SUPER::finalize_error($c);
    } else {
        $c->response->content_type('text/html; charset=utf-8');

        $c->response->body( $c->view('TT')->render( $c, 'errors/500.tt' ) );
        $c->response->status(500);

        my $error = join '', map {"$_\n"} @{ $c->error };

        # Don't show context in the dump
        delete $c->req->{'_context'};
        delete $c->res->{'_context'};

        # Don't show body parser in the dump
        delete $c->req->{'_body'};

        # Don't show response header state in dump
        delete $c->res->{'_finalized_headers'};

        my $to      = 'tan.webmaster@thisaintnews.com';
        my $subject = 'TAN 500 Error: ' . $error;
        $subject =~ s/\s+/ /g;
        $subject = substr( $subject, 0, 200 );
        my $from = $ENV{'ADMIN_EMAIL'} || 'tan.webmaster@thisaintnews.com';

        my $req = {};
        $req->{'uri'} = $c->req->uri || '';
        $req->{'referer'} = $c->req->referer || '';
        $req->{'address'} = $c->req->address || '';

        my $body
            = "Error:\n"
            . $error
            . "\n\nURL:\n"
            . $req->{'uri'}
            . "\n\nReferer:\n"
            . $req->{'referer'}
            . "\n\nClient IP:\n"
            . $req->{'address'};

        $c->email(
            header => [
                'To'      => $to,
                'From'    => $from,
                'Subject' => $subject,
            ],
            parts => [
                Email::MIME->create(
                    'attributes' => {
                        'content_type' => 'text/plain',
                        'disposition'  => 'inline',
                        'charset'      => 'UTF-8',
                    },
                    'body' => $body,
                ),
                Email::MIME->create(
                    'attributes' => {
                        'filename'     => 'request.txt',
                        'content_type' => 'text/plain',
                        'disposition'  => 'attachment',
                        'charset'      => 'UTF-8',
                    },
                    'body' => Dumper( $c->req ),
                ),
                Email::MIME->create(
                    'attributes' => {
                        'filename'     => 'stash.txt',
                        'content_type' => 'text/plain',
                        'disposition'  => 'attachment',
                        'charset'      => 'UTF-8',
                    },
                    'body' => Dumper( $c->stash ),
                ),
            ],
        );
    }
}

=head1 SYNOPSIS

    script/tan_server.pl

=head1 SEE ALSO

L<TAN::Controller::Root>, L<Catalyst>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

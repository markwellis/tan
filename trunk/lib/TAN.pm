package TAN;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Number::Format;
use Data::Dumper;
use Tie::Hash::Indexed;
use Time::HiRes qw/time/;
use POSIX qw/floor/;

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

use Catalyst qw/
    ConfigLoader
    Authentication
    Email
    Session
    Session::Store::File
    Session::State::Cookie
    Cache
    PageCache
    Unicode::Encoding
    Event
/;

extends 'Catalyst';

our $VERSION = 1.4.5;

# Configure the application.
#
# Note that settings in tan.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name => 'TAN', 
    'Plugin::PageCache' => {
        'cache_hook' => 'check_cache',
        'key_maker' => sub {
            my $c = shift;
            my $path = $c->req->path || 'index';

            return "/${path}" . $c->nsfw;
        },
        'no_expire' => 0,
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

#recored p.i.
    if ( ($c->action eq 'view/index') && (!$c->stash->{'pi_recorded'}) ){
        my @params = split('/', $c->req->path);
        my $object_id = $params[2];
        my $session_id = $c->sessionid;
        my $ip_address = $c->req->address;

        if ( $object_id  && $session_id ){
            my $user_id = $c->user_exists ? $c->user->user_id : 0;

            $c->model('MySQL::Views')->update_or_create({
                'session_id' => $session_id,
                'object_id' => $object_id,
                'user_id' => $user_id,
                'ip' => $ip_address,
                'created' => \'NOW()',
                'type' => 'internal',
            },{
                'key' => 'session_objectid',
            });
        }
        #stop duplicate recordings
        $c->stash->{'pi_recorded'} = 1;
    }
    
    if ( 
        $c->user_exists
        || defined($c->stash->{'no_page_cache'})
        || defined($c->stash->{'message'})
        || ($c->res->status > 300)
    ){
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
        $c->res->cookies->{'nsfw'} = {
            'value' => $value,
            'expires' => '+3Y',
        };

        return $value;
    }

    my $nsfw_res = $c->res->cookies->{'nsfw'};
    my $nsfw_req = $c->req->cookies->{'nsfw'};

    my $nsfw_res_val = $nsfw_res->value if ( defined($nsfw_res) );
    my $nsfw_req_val = $nsfw_req->value if ( defined($nsfw_req) );

    return $nsfw_res_val || $nsfw_req_val || 0;
}

=head2 recent_comments

B<@args = undef>

=over

returns the 20 most recent comments

=back

=cut
sub recent_comments{
    my $c = shift;

    my $recent_comments = $c->model('MySQL::Comments')->recent_comments( $c->config->{'recent_comments'} );

    tie my %grouped_comments, 'Tie::Hash::Indexed';
    foreach my $comment ( @{$recent_comments} ){
        if ( !defined($grouped_comments{$comment->object_id}) ){
            $grouped_comments{$comment->object_id} = [];
        }
        push(@{$grouped_comments{$comment->object_id}}, $comment);
    }

    return \%grouped_comments;
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
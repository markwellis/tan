package TAN;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Data::Dumper; #used in 500 error email

use Catalyst qw/
    ConfigLoader
    Authentication
    Authorization::Roles
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

our $VERSION = 2.0.3;

__PACKAGE__->config( name => 'TAN', 
    'Plugin::PageCache' => {
        'cache_hook' => 'check_cache',
        'disable_index' => 0, 
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

sub check_cache{
    my $c = shift;

# this is a hack so people who have messages dont hit the page cache
# its here coz it no worko in the end/render
    $c->stash->{'message'} = $c->flash->{'message'};

#recored p.i.
    if ( 
        !$c->stash->{'pi_recorded'} 
        && ( $c->action ne 'thumb/index' )
        && ( $c->action ne 'minifier/index' )
    ){
        my @params = split('/', $c->req->path);

        my $object_id = ( $c->action eq 'view/index' ) ? $params[2] : undef;
        my $session_id = $c->sessionid;
        my $ip_address = $c->req->address;

        if ( $session_id ){
            my $user_id = $c->user_exists ? $c->user->user_id : undef;

            eval{
            #might get a deadlock [284] - ignore in that case
                $ENV{DBIC_NULLABLE_KEY_NOWARN} = 1; #we *do* want to lookup with a null value, so stop the warning about this is probably not what we want
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
                delete $ENV{DBIC_NULLABLE_KEY_NOWARN};
            };
        }
        #stop duplicate recordings
        $c->stash->{'pi_recorded'} = 1;
    }
    
    if ( 
        $c->user_exists
        || defined($c->stash->{'no_page_cache'})
        || defined($c->stash->{'message'})
        || ($c->res->status > 300)
        || ( $c->req->user_agent =~ m/(?:iPhone|Android)/ )
    ){
        return 0;
    }
    return 1;
}

#filter is off if 1
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

sub finalize_error {
    my ($c) = @_;

    if ( $c->debug ) {
        $c->SUPER::finalize_error($c);
    } else {
        $c->response->content_type('text/html; charset=utf-8');

        $c->forward('/server_error');
        $c->view->process( $c );

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

1;

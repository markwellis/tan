package TAN;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.90;
use Data::Dumper::Concise; #used in 500 error email
use 5.020;

our $VERSION = 6.005018;
$VERSION = eval $VERSION;

use Catalyst qw/
    ConfigLoader
    Authentication
    Authorization::Roles
    Session
    Session::Store::File
    Session::State::Cookie
    Cache
    Event
/;

extends 'Catalyst';

sub mobile{
    my ( $c ) = @_;

    my $action = $c->action;
    my $mobile_allowed;

    my $class = $action->class;
    $class =~ s/TAN::Controller:://;

    my $controller = $c->controller( $class );
    if ( defined( $controller ) && $controller->can('_mobile') ){
        $mobile_allowed = $controller->_mobile->{ $action->name };
    }

    if ( !$mobile_allowed ){
        return 0;
    }

    my $mobile_user =
        $c->stash->{'mobile_switch'}
        || (
            $c->req->cookie('mobile')
            && $c->req->cookie('mobile')->value == 1
        );

    return $mobile_user || 0;
}

#filter is off if 1
sub nsfw{
    my ($c, $value) = @_;

    if ( defined( $value ) ){
        $c->res->cookies->{'nsfw'} = {
            'value' => $value,
            'expires' => '+10y',
        };

        return $value;
    }

    my $nsfw_res_val = 0;
    my $nsfw_req_val = 0;

    if ( my $nsfw_res = $c->res->cookies->{'nsfw'} ){
        $nsfw_res_val = $nsfw_res->{'value'};
    } elsif ( my $nsfw_req = $c->req->cookie('nsfw') ){
        $nsfw_req_val = $nsfw_req->value;
    }

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
        my $from = 'tan.webmaster@' . $c->config->{mail_domain};

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

        my $stash = Dumper( $c->stash );
        $req = Dumper( $c->req );
        $c->model('Email')->send(
            'to'      => $to,
            'from'    => $from,
            'subject' => $subject,
            'plaintext' => $body,
            'attachment' => [
                [\$req, 'request.txt', 'text/plain'],
                [\$stash, 'stash.txt', 'text/plain'],
            ],
        );
    }
}

sub check_usr_tcs{
    my $c = shift;

    if ( $c->user_exists ){
        my $user_tcs = $c->user->tcs // -1;
        if ( $user_tcs != $c->model('DB::Cms')->load('tcs')->revision ){
            return 0;
        }
    }

    return 1;
}

after setup_finalize => sub {
    my $c = shift;

    $c->log->autoflush(0);
};

around dispatch => sub {
    my $orig = shift;
    my $c = shift;

    if ( !$c->req->cookie('mobile') ){
        $c->forward('/mobile/detect_mobile');
    }

    if (
        $ENV{'CATALYST_DEBUG'}
        && $c->log->can('abort')
        && ( $c->action eq 'minify/index')
        && ( !$c->req->param('show_minify') )
    ){
        #don't log minify requests, they're annoying
        $c->log->abort(1);
    }

    my $action = $c->action;
    if (
        $action eq 'view/index'
        || $action eq 'index/index'
    ){
        my $object_id = ( $action eq 'view/index' ) ? $c->req->captures->[-1] : undef;
        my $session_id = $c->sessionid;
        my $ip_address = $c->req->address;

        if ( $session_id ){
            my $user_id = $c->user_exists ? $c->user->user_id : undef;

			$c->model('DB')->txn_do( sub {
				eval{
				#might get a deadlock [284] - ignore in that case
					$c->model('DB::Views')->create({
						session_id  => $session_id,
						object_id   => $object_id,
						user_id     => $user_id,
						ip          => $ip_address,
						created     => \'NOW()',
						type        => 'internal',
					});
				};

				if ( $object_id ) {
					my $object = $c->model('DB::Object')->find( {
							object_id => $object_id,
						} );
					$object->set_column( views	=> $object->distinct_views );
					$object->update;
				}
			} );
        }
    }

    return $c->$orig(@_);
};

__PACKAGE__->setup;

1;

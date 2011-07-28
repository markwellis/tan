package TAN::Controller::Profile::Admin::ContactUser;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub contact_user: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        my $user = $c->stash->{'user'};

        $c->email(
            'header' => [
                'From'    => 'noreply@thisaintnews.com',
                'To'      => $user->email,
                'Subject' => $c->req->param('subject'),
                'Content-Type' => 'text/html',
            ],
            'body' => $c->req->param('body'),
        );

        $c->res->redirect( $user->profile_url, 303 );
        $c->detach;
    }

    $c->stash(
        'template' => 'profile/user/admin/contact_user.tt',
        'page_title' => 'Contact User',
    );
}

__PACKAGE__->meta->make_immutable;

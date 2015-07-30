package TAN::Controller::Profile::Admin::Roles;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {
            'roles' => 1,
        };
    },
);

sub roles: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    my $roles = $c->model('DB::Admin')->search;
    if ( $c->req->method eq 'POST' ){
        my $user = $c->stash->{'user'};
        my @user_roles = $c->req->param('roles');

        if ( scalar( @user_roles ) ){
            $user->set_map_user_role(
                $roles->search( {
                    'role' => \@user_roles,
                } )
            );
        } else {
            $user->delete_related('user_admin');
        }

#update $c->stash->{'user'} roles here
        $c->model('DB::AdminLog')->log_event( {
            'admin_id' => $c->user->id,
            'user_id' => $user->id,
            'action' => 'admin_user',
            'reason' => $c->stash->{'reason'},
        } );

        $c->res->redirect( $user->profile_url, 303 );
        $c->detach;
    }

    $c->stash(
        'template' => 'profile/user/admin/roles.tt',
        'roles' => $roles,
        'page_title' => 'Edit Roles',
    );
}

__PACKAGE__->meta->make_immutable;

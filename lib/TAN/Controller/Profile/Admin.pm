package TAN::Controller::Profile::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub admin: Chained('../user') CaptureArgs(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        #check we have a reason
        my $reason = $c->req->param('reason');
        my $trim_req = $c->model('CommonRegex')->trim;
        $reason =~ s/$trim_req//;

        if ( !$reason ){
            $c->flash->{'message'} = 'No reason given';
            $c->res->redirect( $c->stash->{'user'}->profile_url . 'admin/' . $c->action->name, 303 );
            $c->detach;
        }

        $c->stash->{'reason'} = $reason;
    }

    my $actions = {
        'delete' => {
            'one_of' => [ qw/delete_user/ ],
            'super' => [ qw/god delete_user admin_add_user admin_remove_user/ ],
        },
        'delete_avatar' => {
            'one_of' => [ qw/edit_user/ ],
            'super' => [ qw/god/ ],
        },
        'delete_content' => {
            'one_of' => [ qw/delete_object edit_comment/ ],
            'super' => [ qw/god/ ],
        },
        'roles' => {
            'one_of' => [ qw/admin_user/ ],
            'super' => [ qw/god/ ],
        },
    };

    my $roles = $actions->{ $c->action->name };

    return if ( !$roles ); #no roles required

    if ( 
        $c->check_any_user_role( @{$roles->{'one_of'}} )
        && (
            !$c->check_any_user_role( $c->stash->{'user'}, @{$roles->{'super'}} ) 
            || $c->check_user_roles( qw/god/ ) 
        )
    ){
        return;
    }

    $c->detach('/access_denied');
}

__PACKAGE__->meta->make_immutable;

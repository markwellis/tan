package TAN::Controller::Profile::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub admin: Chained('/profile/user') PathPart('admin') CaptureArgs(0){
#prolly a better way of doing this, but we want the /admin part of the part and /admin does nothing
}

sub check_role: Private{
    my ( $self, $c, $roles, $super_roles ) = @_;

    if ( 
        $c->check_user_roles( @$roles )
        && (
            !$c->check_any_user_role( $c->stash->{'user'}, @$super_roles ) 
            || $c->check_user_roles( qw/god/ ) 
        )
    ){
        return;
    }

    $c->detach('/access_denied');
}

sub _force_logout: Private{
    my ( $self, $c ) = @_;

    my $views_rs = $c->model('MySql::Views')->search( {
        'user_id' => $c->stash->{'user'}->id,
    },{
        'group_by' => 'session_id',
    } );

    foreach my $view ( $views_rs->all ){
        foreach my $key ( ('session','expires') ){
            $c->delete_session_data( "${key}:" . $view->session_id );
        }
    }
}

sub delete: Chained('admin') Args(0){
    my ( $self, $c ) = @_;

    $c->forward( 'check_role', [ [ 'delete_user' ], [ qw/god delete_user admin_add_user admin_remove_user/ ] ] );

    if ( $c->req->method eq 'POST' ){
        #check we have a reason
        my $reason = $c->req->param('reason');
        my $trim_req = $c->model('CommonRegex')->trim;
        $reason =~ s/$trim_req//;

        if ( !$reason ){
            $c->flash->{'message'} = 'No reason given';
            $c->res->redirect( $c->stash->{'user'}->profile_url . 'admin/delete', 303 );
            $c->detach;
        }
        
        #toggle delete
        $c->stash->{'user'}->update( {
            'deleted' => ( $c->stash->{'user'}->deleted eq 'Y' ) ? 'N' : 'Y',
        } );

        $c->forward('_force_logout');
#log action - reason
# ^ link to delete reason on profile page?
#send email

        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
    }

    $c->stash->{'template'} = 'Profile::Admin::Delete';
}

sub contact: Chained('admin') Args(0){
    my ( $self, $c ) = @_;

#send email to user 
}

sub remove_avatar: Chained('admin') Args(0){
    my ( $self, $c ) = @_;

#log reason
#remove avatar
}

sub change_username: Chained('admin') Args(0){
    my ( $self, $c ) = @_;

#log reason
#change username
#remove all sessions for user_id
#email user
}

sub remove_content: Chained('admin') Args(0){
    my ( $self, $c ) = @_;

#log reason
#remove content
#trigger mass purge event *NEW*

}

__PACKAGE__->meta->make_immutable;

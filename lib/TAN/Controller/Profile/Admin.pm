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
            'required' => [ qw/delete_user/ ],
            'super' => [ qw/god delete_user admin_add_user admin_remove_user/ ],
        },
        'delete_avatar' => {
            'required' => [ qw/edit_user/ ],
            'super' => [ qw/god/ ],
        },
    };

    my $roles = $actions->{ $c->action->name };

    return if ( !$roles ); #no roles required

    if ( 
        $c->check_user_roles( @{$roles->{'required'}} )
        && (
            !$c->check_any_user_role( $c->stash->{'user'}, @{$roles->{'super'}} ) 
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

sub contact: Chained('admin') Args(0){
    my ( $self, $c ) = @_;

#send email to user 
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

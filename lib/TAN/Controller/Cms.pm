package TAN::Controller::Cms;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub cms: Private{
    my ( $self, $c ) = @_;

#do caching of somekind
    my $cms = $c->model('MySql::Cms')->find( $c->req->path );

    if ( defined( $cms ) ){
# set page_title as well
        $c->stash(
            'cms' => $cms,
            'template' => 'cms.tt',
        );
        #make sure we detach if is a valid cms url
        $c->detach;
    }

}

__PACKAGE__->meta->make_immutable;

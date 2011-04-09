package TAN::Controller::Submit::Edit;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub validate_user: PathPart('edit') Chained('../type') CaptureArgs(1){
    my ( $self, $c, $object_id ) = @_;

    my $object = $c->model('MySQL::Object')->get( $object_id, $c->stash->{'type'} );

    if ( 
        !defined($object)
        || (
            !$c->check_user_roles(qw/edit_object/) 
            && ( $c->user->id != $object->user_id )
        )
    ){
        $c->detach('/access_denied');
    }

    $c->stash(
        'object' => $object,
        'edit' => 1,
    );
}

sub index: PathPart('') Chained('validate_user') Args(){
    my ( $self, $c ) = @_;

    my $type = $c->stash->{'type'};
    $c->stash(
        'template' => 'Submit',
        'page_title' => 'Edit ' . ($c->stash->{'object'}->$type->title || ''),
    );
}

sub post: PathPart('post') Chained('validate_user') Args(){
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'};
    my $redirect_url;
    if ( 
        defined( $c->req->param('delete') )
        && ( $c->req->param('delete') eq 'Delete' ) 
        && $c->check_user_roles(qw/delete_object/)
    ){
        $c->model('MySql::AdminLog')->log_event( {
            'admin_id' => $c->user->id,
            'user_id' => $object->user_id,
            'action' => 'delete_object',
            'reason' => ' ', #provide this somehow
            'object_id' => $object->id,
        } );

        $object->update( {
            'deleted' => 'Y',
        } );
        $c->trigger_event( 'object_deleted', $object );

        $redirect_url = "/index/all/0/";
    } else {
        my $prepared = $c->forward('/submit/validate_and_prepare');
        my $tags = delete( $prepared->{'tags'} );

        $c->model('MySQL')->txn_do( sub {
            $c->forward( 'update_object', [ $prepared ] );

            $c->forward( 'update_tags', [ $tags ] );

            $c->trigger_event( 'object_updated', $object );
        } );

        $redirect_url = $object->url;
    }

    $c->flash->{'message'} = 'Edit complete';
    $c->res->redirect( $redirect_url, 303 );

    $c->detach();
}

sub update_object: Private{
    my ( $self, $c, $prepared ) = @_;
    
    my $object = $c->stash->{'object'};
    $object->update( {
        'nsfw' => defined( $c->req->param('nsfw') ) ? 'Y' : 'N',
    } );

    my $type = $c->stash->{'type'};

    my $to_update = {};
    my $original = {};

    foreach my $key ( keys( %{$prepared} ) ){
        if ( ref( $prepared->{ $key } ) eq 'ARRAY' ){
            my @existing = $object->$type->$key->search->all;
            $original->{ $key } = \@existing;

            foreach my $new ( @{$prepared->{ $key }} ){
                my $found = shift( @existing );

                if ( $found ){
                    $found->update( $new );
                } else {
                    $object->$type->$key->create( $new );
                }
            }
            foreach my $spare ( @existing ){
                $spare->delete;
            }
        } else {
            my $original_value = $object->$type->$key;
            if ( $original_value ne $prepared->{ $key } ){
                $original->{ $key } = $original_value;
                $to_update->{ $key } = $prepared->{ $key };
            }
        }
    }
warn Data::Dumper::Dumper( $original );
warn Data::Dumper::Dumper( $to_update );
    $object->$type->update( $to_update );
}

sub update_tags: Private{
    my ( $self, $c, $tags ) = @_;

    my @tags = split(/ /, lc($tags));

    my $object = $c->stash->{'object'};

    my %existing_tags = map { $_->tag => $_ } $object->tags->all;
    my %new_tags = map { $_ => 1 } @tags;

    foreach my $tag ( keys( %new_tags ) ){
        if ( $existing_tags{ $tag } ){
            delete( $existing_tags{ $tag } );
            delete( $new_tags{ $tag } );
        }
    }
    my @tags_to_remove = values( %existing_tags );
    my @tags_to_add = keys( %new_tags );

    my $tag_reg = $c->model('CommonRegex')->not_alpha_numeric;
    my $trim_reg = $c->model('CommonRegex')->trim;

    foreach my $tag ( @tags_to_add ){
        $tag =~ s/$tag_reg//g;
        $tag =~ s/$trim_reg//g;
        next if ( !$tag );

        if ( defined($tag) ){
            $object->add_to_tags({
                'tag' => $tag,
            });
        }
    }

    foreach my $spare ( @tags_to_remove ){
        $object->remove_from_tags( $spare );
    }
}

__PACKAGE__->meta->make_immutable;

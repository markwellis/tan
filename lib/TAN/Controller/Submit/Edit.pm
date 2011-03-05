package TAN::Controller::Submit::Edit;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub validate_user: PathPart('edit') Chained('../location') CaptureArgs(1){
    my ( $self, $c, $object_id ) = @_;

    $c->stash->{'object'} = $c->model('MySQL::Object')->get( $object_id, $c->stash->{'location'} );

    if ( 
        !defined($c->stash->{'object'})
        || !$c->user_exists 
        || (
            !$c->user->admin 
            && ($c->user->id != $c->stash->{'object'}->user_id)
        )
    ){
        $c->forward('/default');
        $c->detach();
    }

    $c->stash(
        'edit' => 1,
    );
}

sub index: PathPart('') Chained('validate_user') Args(){
    my ( $self, $c ) = @_;

    my $type = $c->stash->{'location'};
    $c->stash(
        'template' => 'Submit',
        'page_title' => 'Edit ' . ($c->stash->{'object'}->$type->title || ''),
    );
}

sub post: PathPart('post') Chained('validate_user') Args(){
    my ( $self, $c ) = @_;

    my $prepared = $c->forward('/submit/validate_and_prepare');
    my $tags = delete( $prepared->{'tags'} );

    $c->model('MySQL')->txn_do( sub {
        $c->forward( 'update_object', [ $prepared ] );

        $c->forward( 'update_tags', [ $tags ] );

        $c->trigger_event( 'object_updated', $c->stash->{'object'} );
    } );

    $c->flash->{'message'} = 'Edit complete';

    $c->res->redirect( $c->stash->{'object'}->url, 303 );
    $c->detach();
}

sub update_object: Private{
    my ( $self, $c, $prepared ) = @_;
    
    $c->stash->{'object'}->update( {
        'nsfw' => defined( $c->req->param('nsfw') ) ? 'Y' : 'N',
    } );

    my $location = $c->stash->{'location'};

    my $to_update = {};
    foreach my $key ( keys( %{$prepared} ) ){
        if ( ref( $prepared->{ $key } ) eq 'ARRAY' ){
            my @existing = $c->stash->{"object"}->$location->$key->search->all;

            foreach my $new ( @{$prepared->{ $key }} ){
                my $found = shift( @existing );

                if ( $found ){
                    $found->update( $new );
                } else {
                    $c->stash->{"object"}->$location->$key->create( $new );
                }
            }
            foreach my $spare ( @existing ){
                $spare->delete;
            }
        } else {
            if ( $c->stash->{'object'}->$location->$key ne $prepared->{ $key } ){
                $to_update->{ $key } = $prepared->{ $key };
            }
        }
    }

    $c->stash->{'object'}->$location->update( $to_update );
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

package TAN::Controller::Submit;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;
use Scalar::Util 'blessed';

sub location: PathPart('submit') Chained('/') CaptureArgs(1){
    my ( $self, $c, $location ) = @_;

    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/', 303);
        $c->detach();
    }

    my $location_reg = $c->model('CommonRegex')->location;
    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }
    $c->stash(
        'page_title' => 'Submit ' . ucfirst($location),
        'location' => $location,
    );
}

sub index: PathPart('') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'Submit';
}

sub post: PathPart('post') Chained('location') Args(0){
    my ( $self, $c ) = @_;

    my $prepared = $c->forward('validate_and_prepare');

    my $tags = delete( $prepared->{'tags'} );

    my $object;
    $c->model('MySQL')->txn_do( sub {
        $object = $c->forward( 'create_new', [ $prepared ] );

        $c->forward( 'add_tags', [ $object, $tags ] ) if ( defined( $object ) );
    });

    $c->trigger_event('object_created', $object);

    $c->flash->{'message'} = 'Submission complete';

    $c->res->redirect("/index/@{[ $c->stash->{'location'} ]}/1/", 303);
    $c->detach();
}

sub validate_and_prepare: Private{
    my ( $self, $c ) = @_;

    return try {
        $c->model('Submit')->validate_and_prepare( $c, $c->req->params );
    } catch {
        if ( blessed( $_ ) ){
            if ( $_->isa('Exception::Simple') ){
                my $error = $_->error;
                if ( $_->can('url') || !$c->req->param('no_error') ){
                    $c->flash->{'message'} = $_->error;
                }
                $c->flash->{'params'} = $c->req->params;

                if ( $_->can('url') ){
                    $c->res->redirect( $_->url, 303 );
                    $c->detach;
                }
            } elsif ( $_->can('rethrow') ){
                # not our error
                $_->rethrow;
            }
        } else {
        #probably not a user facing error
            die $_;
        }
        if ( $c->stash->{'edit'} ){
            $c->res->redirect("/submit/@{[ $c->stash->{'location'} ]}/edit/@{[ $c->stash->{'object'}->id ]}/", 303);
        } else {
            $c->res->redirect("/submit/@{[ $c->stash->{'location'} ]}/", 303);
        }
        $c->detach;
    };
}

sub create_new: Private{
    my ( $self, $c, $prepared ) = @_;
    
    my $type = $c->req->param('type');
    return $c->model('MySQL::Object')->create({
        'type' => $type,
        'created' => \'NOW()',
        'promoted' => 0,
        'user_id' => $c->user->user_id,
        'nsfw' => defined($c->req->param('nsfw')) ? 'Y' : 'N',
        $type => $prepared,
        'plus_minus' => [{
            'type' => 'plus',
            'user_id' => $c->user->user_id,
        }],
    });
}

sub add_tags: Private {
    my ( $self, $c, $object, $tags ) = @_;

    my @tags = split(/ /, lc($tags));

    my $tags_done = {};

    my $tag_reg = $c->model('CommonRegex')->not_alpha_numeric;
    my $trim_reg = $c->model('CommonRegex')->trim;

    foreach my $tag ( @tags ){
        $tag =~ s/$tag_reg//g;
        $tag =~ s/$trim_reg//g;
        next if ( !$tag );

        if ( !defined($tags_done->{ $tag }) ){
            $tags_done->{ $tag } = 1;

            if ( defined($tag) ){
                $object->add_to_tags({
                    'tag' => $tag,
                });
            }
        }
    }
}

__PACKAGE__->meta->make_immutable;

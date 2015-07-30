package TAN::Controller::View::Poll;
use parent 'Catalyst::Controller';

use Moose;
use namespace::autoclean;

sub vote: PathPart('_vote') Chained('../type') Args(0) {
    my ( $self, $c ) = @_;

    if ( !$c->user_exists ) {
        if ( defined($c->req->param('json')) ){
            $c->stash(
                current_view => 'JSON',
                json_data    => { login => 1 },
            );
        } else {
            $c->res->redirect( '/login/', 303 );
        }

        $c->detach;
    }

    my $poll = $c->model('DB::Poll')->find( {
        'poll_id' => $c->stash->{'object_id'},
    } );

    if ( !$poll || !$c->req->param('answer_id') ){
        $c->forward('/default');
        $c->detach;
    }

    if ( $poll ){
        my $vote = $poll->vote( $c->user->user_id, $c->req->param('answer_id') );
        if ( $vote ){
            $c->trigger_event('poll_vote', $poll);
        }
    }

    if ( !defined( $c->req->param('json') ) ) {
        $c->res->redirect( $poll->object->url, 303 );
        $c->detach;
    }

    my @results;
    #have to get_column because there's a relationship called votes
    my $total_votes = $poll->get_column( 'votes' );
    my $answers = $poll->answers->search( {}, {
            order_by    => 'answer_id',
        } );
    while ( my $answer = $answers->next ) {
        push(
            @results,
            {
                'name'    => $answer->answer,
                'percent' => $answer->percent( $total_votes ),
            }
        );
    }
    $c->stash(
        current_view    => 'JSON',
        json_data   => \@results,
    );
}

__PACKAGE__->meta->make_immutable;

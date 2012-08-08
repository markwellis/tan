package TAN::Controller::View::Poll;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON;

sub vote: PathPart('_vote') Chained('../type') Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->user_exists ){
    # valid user, do work
        my $poll = $c->model('MySQL::Poll')->find({
            'poll_id' => $c->stash->{'object_id'},
        });

#check that $poll exists
#check that $c->req->param('answer_id') exists
        if ( !$poll || !$c->req->param('answer_id') ){
            $c->forward('/default');
            $c->detach;
        }

        if ( $poll ){
            my $vote;
#check if user has already voted

            $vote = $poll->vote($c->user->user_id, $c->req->param('answer_id'));
            if ( $vote ){
                $c->trigger_event('poll_vote', $poll);
            }
        }

        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            my @results;
            my $total_votes = $poll->votes->count;
            foreach my $answer ( $poll->answers->all ){
                push(@results, {
                    'name' => $answer->answer, 
                    'percent' => $answer->percent($total_votes),
                });
            }
            $c->res->body( to_json(\@results) );
        } else {
        #redirect
            $c->res->redirect( $poll->object->url, 303 );
        }
    } else {
    #prompt for login
        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'login' => 1,
            }) );
        } else {
        #redirect
            $c->res->redirect( '/login/', 303 );
        }
    }
    $c->detach();

}

__PACKAGE__->meta->make_immutable;

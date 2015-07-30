package TAN::Controller::Recent;
use Moose;
use MooseX::MethodAttributes;

extends qw/Catalyst::Controller/;

use Scalar::Util qw/looks_like_number/;

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {'comments' => 1};
    },
);

sub base : PathPart(recent) Chained(/) CaptureArgs(0) {}

sub comments : GET Chained(base) Args(0) {
    my ( $self, $c ) = @_;

    my $recent_comments = $c->model('DB::Comment')->recent;
    my $recent_promoted = $c->model('DB::Object')->recent_promoted;
    my $recent_upcoming = $c->model('DB::Object')->recent_upcoming;

    $c->stash(
        recent_comments => $recent_comments,
        recent_promoted => $recent_promoted,
        recent_upcoming => $recent_upcoming,
        no_wrapper      => $c->req->query_params->{ajax} ? 1 : 0,
    );
}

__PACKAGE__->meta->make_immutable;

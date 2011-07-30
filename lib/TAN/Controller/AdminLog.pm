package TAN::Controller::AdminLog;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

has 'prefetch' => (
    'is' => 'ro',
    'isa' => 'ArrayRef',
    'lazy_build' => 1,
);
sub _build_prefetch{
    return [
        {
            'object' => TAN->model('Object')->public,
        },
        qw/admin user comment/,
    ];
}

sub index: Private{
    my ( $self, $c ) = @_;

    my $page = $c->req->param('page') || 1;

    my $int_reg = $c->model('CommonRegex')->not_int;
    $page =~ s/$int_reg//g;
    $page ||= 1;

    my $admin_logs = try {
        $c->model('MySql::AdminLog')->index( $page );
    } catch {
        $c->detach('/default');
    };

    $c->stash(
        'admin_logs' => $admin_logs,
        'template' => 'admin_log.tt',
    );
}

__PACKAGE__->meta->make_immutable;

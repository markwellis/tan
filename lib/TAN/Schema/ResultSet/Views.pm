package TAN::Schema::ResultSet::Views;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

TAN::Schema::ResultSet::Views

=head1 DESCRIPTION

Views ResultSet

=head1 METHODS

=cut

=head2 whos_online

B<@args = undef>

=over

whos online

=back

=cut
sub whos_online {
    my ( $self ) = @_;

    my $who = $self->result_source->schema->cache->get("whos_online");

    if ( !$who ){
        @{$who} = $self->search({
            'created' => {
                '>' => \'DATE_SUB(NOW(), INTERVAL 5 MINUTE)',
            },
        },{
            'select' => [\'DISTINCT(me.user_id)', 'user.username'],
            'as' => ['user_id', 'username'],
            'join' => 'user',
            'rows' => 10,
        })->all;

        $self->result_source->schema->cache->set("whos_online", $who, 60);
    }

    return $who;
}

=head2 create_comment

B<@args = ($object_id, $user_id, $comment)>

=over

creates a comment 

=back

=cut
sub create_comment {
    my ( $self, $object_id, $user_id, $comment ) = @_;

    my $comment_no = $self->search({
        'user_id' => $user_id,
    })->count;

    my $comment_rs = $self->create({
        'user_id' => $user_id,
        'comment' => $comment,
        'created' => \'NOW()',
        'object_id' => $object_id,
        'number' => $comment_no || 1,
    });

    return $comment_rs;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

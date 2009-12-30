package TAN::Schema::ResultSet::Comments;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

TAN::Schema::ResultSet::Comments

=head1 DESCRIPTION

Comments ResultSet

=head1 METHODS

=cut

=head2 recent_comments

B<@args = undef>

=over

gets the 20 most recent comments

=back

=cut
sub recent_comments {
    my $self = shift;

    return $self->search({
        'me.deleted' => 'N'
    },{
        'order_by' =>  {
            '-desc' => 'me.created',
        },
        'rows' => 20,
        'prefetch' => ['user', 'object'],
    });
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

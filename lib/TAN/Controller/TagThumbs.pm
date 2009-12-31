package TAN::Controller::TagThumbs;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use JSON;
use DBIx::Class::ResultClass::HashRefInflator;

=head1 NAME

TAN::Controller::TagThumbs

=head1 DESCRIPTION

JSON for the pictures with these tags

=head1 EXAMPLE

I</tagthumbs/$tags/>

=head1 METHODS

=cut

=head2 index: Path: Args(1)

B<@args = ($tags)>

=over

returns related picture info in json format

=back

=cut
sub index :Path: Args(1) {
    my ( $self, $c, $tags ) = @_;

    my @split_tags = split(/ /, $tags);

# can't use search with many to many realtionship
# probably a better way to do this
    my @found;
    foreach my $tag ( @split_tags ){
        my $found_tags = $c->model('MySQL::Tags')->find({
           'tag' => $tag,
        });
    
        my $res = $found_tags->tag_objects->search_related('object', {
            'type' => 'picture',
            'nsfw' => 'N',
        }, {
            'select' => ['object.object_id', 'object.nsfw'],
        });
        $res->result_class('DBIx::Class::ResultClass::HashRefInflator');

        push(@found, $res->all);
    }

#some error checking goes here

    $c->res->header('Content-Type' => 'application/json');
    $c->res->body( to_json(\@found) );
    $c->detach();
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

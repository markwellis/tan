package TAN::Controller::TagThumbs;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use JSON;
use DBIx::Class::ResultClass::HashRefInflator;

my $int = qr/\D+/;

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
    
        if ( defined($found_tags) ){
            my $res = $found_tags->tag_objects->search_related('object', {
                'type' => 'picture',
                'nsfw' => 'N',
            }, {
                'select' => ['object.object_id', 'object.nsfw'],
            });
            $res->result_class('DBIx::Class::ResultClass::HashRefInflator');

            push(@found, $res->all);
        }
    }

    my $random = $c->req->param('random');
    $random =~ s/$int//g;

    if ( defined($random) ){
        #little security
        $random = ($random > 50) ? 50 : $random;

        my $res = $c->model('MySQL::Object')->search({
            'type' => 'picture',
            'nsfw' => 'N',
        }, {
            'order_by' => \'RAND()',
            'rows' => $random,
            'select' => ['object_id', 'nsfw'],
        });
        $res->result_class('DBIx::Class::ResultClass::HashRefInflator');

        push(@found, $res->all);
    }

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

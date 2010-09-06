package TAN::Controller::TagThumbs;
use strict;
use warnings;

use parent 'Catalyst::Controller';

use JSON;
use Tie::Hash::Indexed;

=head1 NAME

TAN::Controller::TagThumbs

=head1 DESCRIPTION

JSON for the pictures with these tags

=head1 EXAMPLE

I</tagthumbs/$tags/>

=head1 METHODS

=cut

=head2 index: Path Args(1)

B<@args = ($tags)>

=over

returns related picture info in json format

=back

=cut
my $tag_is_id_reg = qr/^\!(\d+)$/;
sub index: Path Args(1) {
    my ( $self, $c, $all_tags ) = @_;

    my @tags = split(/ /, $all_tags);

    #remove duplicate tags
    my %dupe_free_tags;
    tie my %object_ids, 'Tie::Hash::Indexed';
    foreach my $tag ( @tags ){
        if ( $tag =~ m/$tag_is_id_reg/ ){
            $object_ids{$1} = 1;
        } else {
            $dupe_free_tags{$tag} = 1;
        }
    }

    my @clean_tags = keys( %dupe_free_tags );

    if ( scalar(@clean_tags) ){
        my $tags_rs = $c->model('MySQL::Tags')->search({
            'tag' => \@clean_tags,
        });

        if ( $tags_rs ){
            foreach my $tag_rs ( $tags_rs->all ){
            #have to do this coz of the many_to_many :(
                my $objects_rs = $tag_rs->objects->search({
                    'type' => 'picture',
                    'nsfw' => 'N',
                });
                if ( $objects_rs ){
                    foreach my $object ( $objects_rs->all ){
                        $object_ids{$object->id} = 1;
                    }
                }
            }
        }
    }

    my $not_int_reg = $c->model('CommonRegex')->not_int;

    my $random = $c->req->param('random');
    $random =~ s/$not_int_reg//g if ( defined($random) );

    if ( $random ){
        #little security
        $random = ($random > 50) ? 50 : $random;

        my $randoms_rs = $c->model('MySQL::Object')->search({
            'type' => 'picture',
            'nsfw' => 'N',
        }, {
            'order_by' => \'RAND()',
            'rows' => $random,
        });

        if ( $randoms_rs ){
            foreach my $random ( $randoms_rs->all ){
                $object_ids{$random->id} = 1;
            }
        }
    }

    my @output;
    foreach my $object_id ( keys( %object_ids ) ){
        push(@output, {'object_id' => $object_id});
    }

    $c->res->header('Content-Type' => 'application/json');
    $c->res->body( to_json(\@output) );
    $c->detach();
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

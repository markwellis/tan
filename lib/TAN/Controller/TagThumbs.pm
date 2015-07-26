package TAN::Controller::TagThumbs;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON;
use Tie::Hash::Indexed;

my $tag_is_id_reg = qr/^\!(\d+)$/;
sub index: Args(0) {
    my ( $self, $c ) = @_;

    my $all_tags = $c->req->param('tags');

    my @tags = split(/ /, $all_tags);
    $c->model('Stemmer')->stem_in_place( \@tags );

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
        my $tags_rs = $c->model('DB::Tags')->search({
            'stem' => \@clean_tags,
        });

        if ( $tags_rs ){
            foreach my $tag_rs ( $tags_rs->all ){
            #have to do this coz of the many_to_many :(
                my $objects_rs = $tag_rs->objects->search({
                    'type' => 'picture',
                    'nsfw' => 0,
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

        my $randoms_rs = $c->model('DB::Object')->search({
            'type' => 'picture',
            'nsfw' => 0,
        }, {
            'order_by' => \'random()',
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

__PACKAGE__->meta->make_immutable;

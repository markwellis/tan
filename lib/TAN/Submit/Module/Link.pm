package TAN::Submit::Module::Link;
use Moose;
use namespace::autoclean;

with 'TAN::Submit::Module';

use Try::Tiny;
use Data::Validate::URI;
use Tie::Hash::Indexed;

sub _build_config{

    tie my %schema, 'Tie::Hash::Indexed';
    %schema = (
        'title' => {
            'length' => {
                'min' => 3,
                'max' => 255,
            },
            'type' => 'text',
            'required' => 1,
        },
        'url' => {
            'length' => {
                'max' => 400,
            },
            'type' => 'text',
            'required' => 1,
            'validate' => [
                sub { 
                    my ( $c, $url ) = @_;
                    Exception::Simple->throw("invalid url") if !defined(Data::Validate::URI::is_web_uri( $url )) },
                sub {
                    my ( $c, $url ) = @_;
                        return if ( $c->stash->{'edit'} );

                        my $link_rs = $c->model('MySQL::Link')->find({
                            'url' => $url,
                        });
                        if ( $link_rs ){
                            if ( $link_rs->object->deleted eq 'Y' ){
                                Exception::Simple->throw(
                                    'error' => 'deleted repost',
                                    'url' => '/index/all/0/',
                                );
                            } else {
                                Exception::Simple->throw(
                                    'error' => 'repost',
                                    'url' => $link_rs->object->url,
                                );
                            }
                        }
                },
            ],
        },
        'description' => {
            'length' => {
                'min' => 3,
                'max' => 1000
            },
            'type' => 'textarea',
            'required' => 1,
        },
        'tags' => {
            'type' => 'tags',
            'required' => 1,
        },
        'picture_id' => {
            'type' => 'hidden',
            'required' => 1,
        },
    );

    return {
        'schema' => \%schema,
        'menu' => {
            'position' => 10,
        }
    };
}

__PACKAGE__->meta->make_immutable;

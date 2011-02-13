package TAN::Submit::Module::Blog;

use Moose;
with 'TAN::Submit::Module';

no Moose;

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
        'description' => {
            'length' => {
                'min' => 3,
                'max' => 1000
            },
            'type' => 'textarea',
            'required' => 1,
        },
        'picture_id' => {
            'type' => 'hidden',
            'required' => 1,
        },
        'details' => {
            'length' => {
                'min' => 20,
            },
            'type' => 'wysiwyg',
            'required' => 1,
        },
        'tags' => {
            'type' => 'tags',
            'required' => 1,
        },
    );

    return {
        'schema' => \%schema,
        'menu' => {
            'position' => 20,
        },
    };

    return \%config;
}

__PACKAGE__->meta->make_immutable;

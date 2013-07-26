package TAN::Model::Submit::Module::Blog;
use Moose;
use namespace::autoclean;

with 'TAN::Model::Submit::Module';

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
        'picture_id' => {
            'type' => 'hidden',
            'required' => 1,
        },
    );

    return {
        'alias' => {
            'name' => 'forum',
            'menu' => {
                'position' => 60,
            },
        },
        'schema' => \%schema,
        'menu' => {
            'position' => 20,
        },
    };
}

my $nl_reg = qr/\n\r|\r\n|\n|\r/;
around 'prepare' => sub {
    my ( $orig, $self, $c, $params, $validator_return_values ) = @_;

    #strip newlines from $params->{'details'}
    $params->{'details'} =~ s/$nl_reg//msg;

    return $self->$orig( $c, $params, $validator_return_values );
};

__PACKAGE__->meta->make_immutable;

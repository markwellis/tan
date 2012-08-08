package TAN::Submit::Module::Poll;
use Moose;
use namespace::autoclean;

with 'TAN::Submit::Module';

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
        'end_date' => {
            'length' => {
                'max' => 400,
            },
            'default' => 3,
            'type' => 'text',
            'label' => 'End in this many days',
            'required' => 1,
            'no_edit' => 1,
            'validate' => [
                sub { 
                    my ( $c, $end_date ) = @_;

                    my $not_int_reg = $c->model('CommonRegex')->not_int;

                    $end_date =~ s/$not_int_reg//;
                    if ( !$end_date ){ # 0 would be an invalid end_date as well
                        Exception::Simple->throw('invalid end date');
                    }
                }
            ],
        },
        'answers' => {
            'label' => 'Answer',
            'type' => 'array',
            'minimum' => 2,
            'required' => 1,
            'length' => {
                'min' => 1,
                'max' =>255,
            },
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
            'position' => 40,
        }
    };
}

around 'prepare' => sub {
    my ( $orig, $self, $c, @other ) = @_;
    
    my $prepared = $self->$orig( $c, @other );

    if ( !$c->stash->{'edit'} ){
        my $days = $prepared->{'end_date'};
        #cleaned in validator
        $days = ( $days > 31 ) ? 31 : $days;

        $prepared->{'end_date'} = \"DATE_ADD(NOW(), INTERVAL ${days} DAY)";
    }
    $prepared->{'answers'} = [map( {'answer' => $_}, @{$prepared->{'answers'}} )];

    return $prepared;
};

__PACKAGE__->meta->make_immutable;

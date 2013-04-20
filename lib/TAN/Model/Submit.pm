package TAN::Model::Submit;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Module::Find;
use Exception::Simple;

has 'modules' => (
    'is' => 'ro',
    'isa' => 'HashRef[Object]',
    'init_arg' => undef,
    'builder' => '_build_modules',
);

sub _build_modules{
    #look in current namesapce::Module
    my $namespace = __PACKAGE__ . "::Module";
    my @mods = useall($namespace);

    my $types = {};
    foreach my $mod ( @mods ){
        my $type = $mod;
        $type =~ s/$namespace\:\://;
        $type = lc( $type );
        $types->{ $type } = $mod->new;

        #setup aliases
        if ( my $alias = $types->{ $type }->config->{'alias'} ){
            $types->{ $alias->{'name'} } = $types->{ $type };
        }
    }

    return $types;
}

#returns validator_ret_val
sub _validate{
    my ( $self, $c, $post_data ) = @_;

    Exception::Simple->throw("no params") if ( ref($post_data) ne 'HASH' );
    Exception::Simple->throw("no type") if !$post_data->{'type'};

    my $module = $self->modules->{ $post_data->{'type'} };

    Exception::Simple->throw("invalid type") if !$module;

    my %schema = %{ $module->config->{'schema'} }; #duplicate config so we can delete things from it without it affecting the module
    my @validator_return_values; #we'll use this later, perhaps...

    my $trim_reg = $c->model('CommonRegex')->trim;

    foreach my $post_key ( keys(%{$post_data}) ){
        next if !defined( $post_data->{ $post_key } );
        $post_data->{ $post_key } =~ s/$trim_reg//g;
        next if ( $post_data->{ $post_key } eq '' ); #ignore empty fields

    #what does this do?
        my $schema_item = $schema{ $post_key }; #needs beter name

        #something extra we know nothing about, ignore it
        next if !$schema_item;

        next if ( $c->stash->{'edit'} && $schema_item->{'no_edit'} );

        #type checkings
        if ( my $type = $schema_item->{'type'} ){
            if ( $type eq 'array' ) {
                if ( ref( $post_data->{ $post_key } ) ne 'ARRAY' ){
                    Exception::Simple->throw("${post_key} not an array");
                }

                #remove undef values...
                my @clean_array;
                foreach my $post_array_item ( @{$post_data->{ $post_key }} ){
                    $post_array_item =~ s/$trim_reg//g;
                    push( @clean_array, $post_array_item ) if ( $post_array_item ne '' );
                }
                $post_data->{ $post_key } = \@clean_array;

                if ( scalar( @{$post_data->{ $post_key }} ) < $schema_item->{'minimum'} ){
                    Exception::Simple->throw("not enough ${post_key} provided");
                }
            }
        }

        if ( my $length = $schema_item->{'length'} ){
        #do we have length constraints?
            if ( $length->{'min'} && (length($post_data->{ $post_key }) < $length->{'min'}) ){
                 Exception::Simple->throw("${post_key} must be at least @{[ $length->{'min'} ]} characters");
            }

            if ( $length->{'max'} && (length($post_data->{ $post_key }) > $length->{'max'}) ){
                Exception::Simple->throw("${post_key} must not exceed @{[ $length->{'max'} ]} characters");
            }
        }

        foreach my $validator ( @{ $schema_item->{'validate'} } ){
        #do we have a custom validator?
            my $validator_ret_val = $validator->( $c, $post_data->{ $post_key } );
            push(@validator_return_values, $validator_ret_val) if $validator_ret_val;
        }

        #remove our param key, so we can check if any have been missed
        delete $schema{ $post_key };
    }

    foreach my $post_key ( keys(%schema) ){
    #check for missing params
        next if ( $c->stash->{'edit'} && $schema{$post_key}->{'no_edit'} );

        if ( $schema{$post_key}->{'required'} ){
            Exception::Simple->throw("${post_key} is required");
        }

        if ( my $required_or = $schema{$post_key}->{'required_or'} ){
            if ( $schema{ $required_or } ){
                Exception::Simple->throw("either ${post_key} or ${required_or} must be provided");
            }
        }
    }

    return \@validator_return_values;
}

sub _prepare{
    my ( $self, $c, $params, $validator_return_values ) = @_;

    my $module = $self->modules->{ $params->{'type'} };
    return $module->prepare( $c, $params, $validator_return_values );
}

sub validate_and_prepare{
    my ( $self, $c, $params ) = @_;

    my $valid = $self->_validate( $c, $params );
    my $prepared = $self->_prepare( $c, $params, $valid );

    if ( !scalar(keys(%{$prepared})) ){
        Exception::Simple->throw("prepare failed");
    }
    return $prepared;
}

__PACKAGE__->meta->make_immutable;

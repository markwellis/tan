package TAN::View::Template::Classic::Submit;
use strict;
use warnings;

use base 'Catalyst::View::Perl::Template';
use Try::Tiny;

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'Submit');
    push(@{$c->stash->{'js_includes'}}, 'Submit');

    my $module = $c->model('Submit')->modules->{ $c->stash->{'location'} };

    return undef if !$module;

    my $output = qq\
        <form action="post" id="submit_form" method="post" enctype="multipart/form-data">
            <fieldset>
                <ul>\;

    my $schema = $module->config->{'schema'};
    my $template_prename_reg = qr/Template::\w+::/;

    my $params = $c->flash->{'params'};
    my $location = $c->stash->{'location'};
    my $object = $c->stash->{'object'};

    foreach my $key ( keys( %{$schema} ) ){
        my $field = {
            'id' => $key,
            'label' => $schema->{ $key }->{'label'} || $key,
            'type' => $schema->{ $key }->{'type'},
            'required' => $schema->{ $key }->{'required'} || undef,
            'length' => $schema->{ $key }->{'length'} || undef,
        };

        my $value;
        if ( 
            $c->stash->{'edit'} 
            && defined( $object ) 
            && $object->$location 
        ){
            if (
                ( $location eq 'picture' )
                && ( $key eq 'remote' ) 
            ){
                my $md = $object->picture->id - ( $object->picture->id % 1000 );
	            $value = "@{[ $c->config->{'thumb_path'} ]}/${md}/@{[ $object->picture->id ]}/600";
                $field->{'ignore'} = 1;
            } elsif ( $key eq 'upload' ){
                $value = undef;
                $field->{'ignore'} = 1;
            } elsif ( $key eq 'tags' ){
                my @tags = map( $_->tag, $object->tags->all );
                $value = join( ' ', @tags );
            } elsif( 
                ( $location eq 'poll' )
                && ( $key eq 'end_date' ) 
            ){
                $value = $object->$location->ends || 'Ended';
                $field->{'disabled'} = 1;
            } else {
                $value = $object->$location->$key;
            }
        }
        $field->{'value'} = $params->{ $key } || $value || $schema->{ $key }->{'default'} || '',

        my $template_name = 'Submit::' . ucfirst( $field->{'type'} );


        if ( !$field->{'ignore'} ) {
            my %views;
        #seems like a candidate for refactoring...
            foreach my $view ( $c->views ){
                $view =~ s/$template_prename_reg//;
                $views{ $view } = 1;
            }

            if ( !$views{ $template_name } ){
                $template_name = "Submit::Default";
            }
            
            $output .= qq\
                <li>
                    @{[ $c->view->template( $template_name, $field ) ]}
                </li>\;
        } elsif ( $key eq 'remote' ){
            $output .= qq\
                <li>
                    <img alt="@{[ $object->picture->id ]}" src="@{[ $field->{'value'} ]}" />
                </li>\;
        }
    }

    my $nsfw;
    if ( defined( $object ) ){
        $nsfw = ( $object->nsfw eq 'Y' ) ? 1 : undef; 
    }
    $nsfw = $params->{'nsfw'} || $nsfw || undef;
    $output .= qq\
                    <li>
                        <label for="nsfw">Not Safe for Work?</label>
                        <input type="checkbox" name="nsfw" id="nsfw" @{[ ( $nsfw ) ? 'checked="checked"' : '' ]}/>
                    </li>
                </ul>
                <input type="submit" value="Submit @{[ ucfirst( $c->stash->{'location'} ) ]}"/>
                <input type="hidden" name="type" value="@{[ $c->stash->{'location'} ]}" />
            </fieldset>
        </form>\;

    return qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                ${output}
            </li>
        </ul>\;
}

1;

package TAN::Model::Image;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Data::Validate::Image;
use Exception::Simple;
use File::Copy;

has 'image_validator' => (
    'is' => 'ro',
    'isa' => 'ClassName',
    'lazy' => 1,
    'default' => 'Data::Validate::Image',
);

sub resize{
    my ( $self, $input, $output, $width ) = @_;

    if ( !( -e $input ) ){
        Exception::Simple->throw('file not found');
    }

    my $image_info = $self->image_validator->validate( $input );

    if ( !$image_info || !$image_info->{'width'} || !$image_info->{'height'} ){
    #thumb not an image
        Exception::Simple->throw('not an image');
    }

    my $new_width = $width * ( $image_info->{'width'} / $image_info->{'height'} );
    $new_width = ( $new_width > $width) ? $width : $new_width;

    my $new_height = $new_width * ($image_info->{'height'} / $image_info->{'width'});

    if ( 
        ( $image_info->{'width'} < $width ) 
        && ( $image_info->{'height'} < $width ) 
        && !$image_info->{'animated'} 
    ){
    #don't make image bigger... unless it's amimated. wtf? (i guess because animated gifs can be huge(filesize) )
        copy( $input, $output ) || Exception::Simple->throw("copy failed ${!}");
        return;
    }

    my $retval;
    if ( ($image_info->{'mime'} eq 'image/gif') && ($image_info->{'animated'}) ){
    #GIF
        #HACK - use original image if preview page
        if ( $width == 600 ){
            copy( $input, $output ) || Exception::Simple->throw("copy failed ${!}");
        } else {
            $retval = `convert -background transparent '${input}'[0-10] -coalesce -thumbnail '${new_width}x${new_height}' -layers OptimizePlus '${output}' 2>&1`;
        }
    } else {
        $retval = `convert '${input}' -thumbnail '${new_width}x${new_height}' '${output}' 2>&1`;
    }
    if ( $retval ){
    #exit code 0 is success
        Exception::Simple->throw('resize error');
    }
}

#change this to take resize option
sub crop{
    my ( $self, $infile, $outfile, $x, $y, $w, $h ) = @_;

    if (!`convert -background transparent '${infile}'[0-10] -coalesce -crop '${w}x${h}+${x}+${y}!' -thumbnail '100x100' -gravity center -extent 100x100 -layers OptimizePlus gif:'${outfile}'  2>&1`) {
    #exit code 0 is success :/
        return 1;
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;

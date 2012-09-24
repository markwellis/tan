package TAN::Model::Image;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Data::Validate::Image;
use Exception::Simple;
use File::Copy;
use File::Path qw/mkpath/;
use File::Basename;

has 'image_validator' => (
    'is' => 'ro',
    'isa' => 'ClassName',
    'lazy' => 1,
    'default' => 'Data::Validate::Image',
);

has 'allowed_thumbnail_sizes' => (
    'is' => 'ro',
    'isa' => 'ArrayRef',
    'required' => 1,
);

has 'animated_frame_limit' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'animated_size_showall_frames' => (
    'is' => 'ro',
    'isa' => 'ArrayRef',
    'required' => 1,
);

#TODO
#add flocking

sub thumbnail{
    my ( $self, $input, $output, $width ) = @_;

    mkpath( dirname( $output ) );

    if ( !( -e $input ) ){
        Exception::Simple->throw('file not found');
    }

    if ( !grep( /^${width}$/, @{ $self->allowed_thumbnail_sizes } ) ){
        Exception::Simple->throw('invalid thumbnail size');
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
        ( $new_width > $image_info->{'width'} )
        || ( $new_height > $image_info->{'height'} )
    ){
    #don't make thumbnails bigger than the original image
        if (
            !$image_info->{'animated'}
            || grep( /^${width}$/, @{ $self->animated_size_showall_frames } )
        ){
        #just copy the file if it's not animated
        # or if it's an animation where all the frames are shown
            copy( $input, $output );
            return;
        }
        # else carry on resizing, since we need to drop the framecount down
        $new_width = $image_info->{'width'};
        $new_height = $image_info->{'height'};
    }

    my $retval;
    if ( 
        ( $image_info->{'mime'} eq 'image/gif' ) 
        && ( $image_info->{'animated'} ) 
    ){
        my $frame_limit = "";
        if ( !grep( /^${width}$/, @{ $self->animated_size_showall_frames } ) ){
            $frame_limit = "[0-" . $self->animated_frame_limit . "]";
        }

        $retval = `convert -background transparent '${input}'$frame_limit -coalesce -thumbnail '${new_width}x${new_height}' -layers OptimizePlus '${output}' 2>&1`;
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

    my $frame_limit = "[0-" . $self->animated_frame_limit . "]";
    if (!`convert -background transparent '${infile}'$frame_limit -coalesce -crop '${w}x${h}+${x}+${y}!' -thumbnail '100x100' -gravity center -extent 100x100 -layers OptimizePlus gif:'${outfile}'  2>&1`) {
    #exit code 0 is success :/
        return 1;
    }
    return 0;
}

sub create_blank{
    my ( $self, $output_image ) = @_;

    if ( !`convert null: gif:${output_image} 2>&1` ){
    # returns 0 on success
        return 1;
    }

    Exception::Simple->throw("error creating blank image");
}

__PACKAGE__->meta->make_immutable;

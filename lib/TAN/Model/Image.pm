package TAN::Model::Image;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Path::Tiny;
use Image::Magick;
use Carp;
use POSIX qw/ceil/;
use List::Util qw/any/;

has 'animated_frame_limit' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

has $_  => (
    'is'       => 'ro',
    'isa'      => 'ArrayRef',
    'required' => 1,
) for qw/animated_size_showall_frames allowed_thumbnail_sizes/;

sub thumbnail {
    my ( $self, $input_s, $output_s, $width ) = @_;

    my $input = path( $input_s );
    my $output = path( $output_s );

    if ( !grep { $_ == $width } @{ $self->allowed_thumbnail_sizes } ) {
        croak 'invalid thumbnail size';
    }

    $output->parent->mkpath;

    my $frame_limit;
    if ( any { $_ == $width } @{ $self->animated_size_showall_frames } ) {
        $frame_limit = undef;
    }
    else {
        $frame_limit = $self->animated_frame_limit;
    }
    my @images;

    my ( $image, $frame_count, $filetype ) = $self->_read_image( $input );
    return if !$image;

    my $scalefactor = $width / $image->Get('width');

    if ( $scalefactor > 1 ) {
        #don't make thumbnails bigger than the original image
        if ( $frame_limit ) {
            #just copy the file if it's not animated
            # or if it's an animation where all the frames are shown
            $input->copy( $output );
            return;
        }

        # else carry on resizing, since we need to drop the framecount down
        $scalefactor = 1;
    }

    my $new_width = int( $image->Get('width') * $scalefactor );
    my $new_height = int ( $image->Get('height') * $scalefactor );

    if ( ( $filetype eq 'gif' ) && ( $frame_count > 1 ) ) {
#animated gif
        if ( $frame_limit && ( $frame_count > $frame_limit ) ) {
        #drop framelimit
            $image = $self->_reduce_frames( $image, $frame_limit );
        }

        $image->Set(
            background => 'transparent',
        );
        #look at the api consistency
        # this one returns a new image!
        $image = $image->Coalesce;
        $image->Thumbnail(
            width  => $new_width,
            height => $new_height,
        );
        $image->Layers(
            method  => 'optimize-transparency',
        );
        $image->Layers(
            method  => 'optimize-plus',
        );
    }
    else {
        $image->Thumbnail(
            width  => $new_width,
            height => $new_height,
        );
    }

    $self->_write_image( $output, $image );
}

sub crop {
    my ( $self, $input_s, $output_s, $x, $y, $w, $h ) = @_;

    my $input = path( $input_s );
    my $output = path( $output_s );

    my ( $image, $frame_count, $filetype ) = $self->_read_image( $input );
    return if !$image;

    if ( ( $frame_count > 1 ) && ( $filetype eq 'gif' ) ) {
        $image->Set(
            background => 'transparent',
        );
        $image = $image->Coalesce;
        $image = $self->_reduce_frames( $image, $self->animated_frame_limit );
    }

    $image->Crop(
        width   => $w,
        height  => $h,
        x       => $x,
        y       => $y,
    );
    $image->Thumbnail(
        height  => 100,
        width   => 100,
    );
    $image->Extent(
        width   => 100,
        height  => 100,
        gravity => 'Center',
    );

    $image->Layers(
        method  => 'optimize-transparency',
    );
    $image->Layers(
        method  => 'optimize-plus',
    );

    $self->_write_image( $output, $image );
}

sub _reduce_frames {
    my ( $self, $image, $frame_limit ) = @_;

    #this is a massive hack
    return bless [ @$image[ 0..$frame_limit ] ], 'Image::Magick';
}

sub _read_image {
    my ( $self, $input ) = @_;

    return if !$input->exists;

    my $image = Image::Magick->new;
    my $error = $image->Read( $input );
    die $error if $error;

    if ( wantarray ) {
        return ( $image, scalar @$image, lc $image->Get('magick') );
    }
    return $image;
}

sub _write_image {
    my ( $self, $output, $image ) = @_;

    $output->parent->mkpath;

    my $error = $image->Write( $output );
    die $error if $error;

    1;
}

__PACKAGE__->meta->make_immutable;

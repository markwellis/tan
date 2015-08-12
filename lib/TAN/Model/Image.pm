package TAN::Model::Image;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Path::Tiny;
use Imager;
use Carp;
use POSIX qw/ceil/;

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

    my @images = $self->_read_image( $input );
    my $filetype = $self->_image_type( $images[0] );
    my $frames = scalar @images;

    my $scalefactor = $width / $images[0]->getwidth;

    if ( $scalefactor > 1 ) {
        #don't make thumbnails bigger than the original image
        if (
            $frames == 1
            || grep {$_ == $width } @{ $self->animated_size_showall_frames }
        ) {
            #just copy the file if it's not animated
            # or if it's an animation where all the frames are shown
            $input->copy( $output );
            return;
        }

        # else carry on resizing, since we need to drop the framecount down
        $scalefactor = 1;
    }

    my @thumbs;
    my $frame_limit = $frames - 1;

    if (
        ( $filetype eq 'gif' )
        && ( $frames > $self->animated_frame_limit )
        && !grep {$_ == $width } @{ $self->animated_size_showall_frames }
    ) {
        $frame_limit = $self->animated_frame_limit;
    }

    foreach my $image ( @images[0..$frame_limit] ) {
        my $thumb = $image->scale(
            scalefactor => $scalefactor,
        );
        if ( $scalefactor < 0.5 ) {
        #sharpen the thumb
            $thumb->filter(
                type=>"conv", coef=>[ -0.3, 2, -0.3 ]
            );
        }

        $self->_copy_tags( $image, $thumb );
        foreach my $tag ( qw/gif_left gif_top gif_screen_width gif_screen_height/ ) {
            my $original_value = $thumb->tags( name => $tag );
            next if !defined $original_value;

            $thumb->settag(
                name    => $tag,
                value   => ceil( $original_value * $scalefactor ),
            );
        }


        push @thumbs, $thumb;
    }

    $self->_write_image( $output, $filetype, \@thumbs );
}

#change this to take resize option
sub crop {
    my ( $self, $input_s, $output_s, $left, $top, $width, $height ) = @_;

    my $input = path( $input_s );
    my $output = path( $output_s );

    my @images = $self->_read_image( $input );
    my $filetype = $self->_image_type( $images[0] );
    my $frames = scalar @images;

    my $frame_limit = $frames - 1;
    if (
        ( $filetype eq 'gif' )
        && ( $frames > $self->animated_frame_limit )
    ) {
        $frame_limit = $self->animated_frame_limit;
    }

    my @cropped;
    foreach my $image ( @images[0..$frame_limit] ) {
        my ( $existing_left, $existing_top ) = ( 0 ) x 2;
        my $new_left = $left;
        my $new_top = $top;

        if ( $filetype eq 'gif' ) {
            $new_left -= $image->tags( name => 'gif_left') ;
            $new_top -= $image->tags( name => 'gif_top');
        }

        my $new = $image->crop(
            left   => $new_left,
            top    => $new_top,
            width  => $width,
            height => $height,
        );
        next if !$new;

        $self->_copy_tags( $image, $new );
        if ( $filetype eq 'gif' ) {
            my $layer_left = $new->tags( name => 'gif_left') - $left;
            $layer_left = 0 if $layer_left < 0;

            my $layer_top = $new->tags( name => 'gif_top') - $top;
            $layer_top = 0 if $layer_top < 0;

            $new->settag(
                name    => 'gif_left',
                value   => $layer_left,
            );
            $new->settag(
                name    => 'gif_top',
                value   => $layer_top,
            );
            $new->settag(
                name    => 'gif_screen_width',
                value   => $width,
            );
            $new->settag(
                name    => 'gif_screen_height',
                value   => $height,
            );
        }

        push @cropped, $new;
    }

    $self->_write_image( $output, $filetype, \@cropped );
}

sub create_blank {
    my ( $self, $output_filename_s ) = @_;

    my $output_filename = path( $output_filename_s );

    my $image = Imager->new(
        xsize       => 1,
        ysize       => 1,
        channels    => 4
    );
    $image->box(
        filled      => 1,
        color       => '#00000000',
    );

    $self->_write_image( $output_filename, 'gif', [$image] );
}

sub _read_image {
    my ( $self, $input ) = @_;

    if ( !$input->exists ) {
        croak 'file not found';
    }

    my @images = Imager->read_multi(
        file => $input,
    ) or croak "open image failed " . Imager->errstr;

    return @images;
}


sub _write_image {
    my ( $self, $output, $filetype, $images ) = @_;

    $output->parent->mkpath;

    Imager->write_multi(
        {
            file            => $output,
            type            => $filetype,
            jpegquality     => 95,
            jpeg_optimize   => 1,
            gif_local_map => 1,
            make_colors => 'addi',
            translate => 'closest',
            transp => 'errdiff',
        },
        @$images
    ) or croak 'write image  error ' . Imager->errstr;
}

sub _copy_tags {
    my ( $self, $source, $target ) = @_;

    for my $tag ( $source->tags ) {
        $target->addtag(
            name    => $tag->[ 0 ],
            value   => $tag->[ 1 ],
        );
    }
}

sub _image_type {
    my ( $self, $image ) = @_;

    return $image->tags( name => 'i_format' );
}

__PACKAGE__->meta->make_immutable;

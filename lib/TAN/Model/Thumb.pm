package TAN::Model::Thumb;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Data::Validate::Image;

=head1 NAME

TAN::Model::Thumb

=head1 DESCRIPTION

Resizes an image

=head1 METHODS

=cut

=head2 BUILD

B<@args = undef>

=over

sets debugobj to new TAN::DBProfiler

=back

=cut
sub BUILD{
    my ($self) = @_;

    $self->{'image_validator'} = new Data::Validate::Image;

    return $self;
}

=head2 resize

B<@args = ($filename, $cacheimg, $x)>

=over

resizes $filename to $x, writes it to $cacheimg

=back

=cut
sub resize{
    my ($self, $filename, $cacheimg, $x) = @_;

    if ( -e $filename ){
        my $image_info = $self->{'image_validator'}->is_image( $filename );

        my ($new_x, $new_y);

        $new_x = $x * ($image_info->{'x'} / $image_info->{'y'});
        $new_x = ($new_x > $x) ? $x : $new_x;

        $new_y = $new_x * ($image_info->{'y'} / $image_info->{'x'});

        $new_x = int($new_x);
        $new_y = int($new_y);

        if ( ($image_info->{'x'} < $x) && ($image_info->{'y'} < $x) && ($image_info->{'mime'} ne 'image/gif') ){
        #return original image or something if smaller than thumb (NOT FOR GIFS!)
            return `cp '${filename}' '${cacheimg}'`;
        }

        my $retval;
        if ( $image_info->{'mime'} eq 'image/gif' ){
        #GIF
            $retval = `convert '${filename}'[0-10] -coalesce -thumbnail '${new_x}x${new_y}>' -layers Optimize '${cacheimg}' 2>&1`;
        } else {
            $retval = `convert '${filename}' -thumbnail '${new_x}x${new_y}' '${cacheimg}' 2>&1`;
        }
        if ( (-s $filename) < (-s $cacheimg) ){
        #thumbnail is bigger than original :/
            return `cp '${filename}' '${cacheimg}'`;
        }
        return $retval;
    }
    return 'error';
}

=head2 crope

B<@args = ($infile, $outfile, $x, $y, $w, $h)>

=over

crops and resizes $infile to 100x100

writes to $outfile

=back

=cut
sub crop{
    my ( $self, $infile, $outfile, $x, $y, $w, $h ) = @_;

    if (!`convert -background transparent '${infile}'[0-10] -coalesce -crop '${w}x${h}+${x}+${y}!' -thumbnail '100x100' -gravity center -extent 100x100 -layers Optimize gif:${outfile}`) {
    #exit code 0 is success :/
        return 1;
    }
    return 0;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

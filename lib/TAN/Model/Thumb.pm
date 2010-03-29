package TAN::Model::Thumb;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Image::Size;

=head1 NAME

TAN::Model::Thumb

=head1 DESCRIPTION

Resizes an image

=head1 METHODS

=cut

=head2 resize

B<@args = ($filename, $cacheimg, $x)>

=over

resizes $filename to $x, writes it to $cacheimg

=back

=cut
sub resize{
    my ($self, $filename, $cacheimg, $x) = @_;

    if ( -e $filename ){
    
        my ($old_x, $old_y) = imgsize($filename);
        my ($new_x, $new_y);

        $new_x = $x * ($old_x / $old_y);
        $new_x = ($new_x > $x) ? $x : $new_x;

        $new_y = $new_x * ($old_y / $old_x);

        $new_x = int($new_x);
        $new_y = int($new_y);

        if ( ($old_x < $x) && ($old_y < $x) ){
            #return original image or something
            return `cp '${filename}' '${cacheimg}'`;
        }

        return `convert '${filename}'[0-10] -coalesce -auto-orient -thumbnail '${new_x}x${new_y}>' -layers Optimize '${cacheimg}' 2>&1`;
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

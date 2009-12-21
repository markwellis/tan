package Data::Validate::Image;

use strict;
use warnings;

use Moose;
use Image::Info;

=head1 NAME

Data::Validate::Image - Validates an image

=head1 SYNOPSIS

stuff goes here

=head1 DESCRIPTION

Confirms that an image is infact an image

=head2 EXPORTS

Exports nothing

=head1 SEE ALSO

L<Image::Info>

=head1 AUTHORS

Copyright 2009 mrbig4545 at thisaintnews.com

=head1 LICENSE

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl v5.10.1 itself.

=cut

sub is_image{
    my ($self, $file) = @_;

    return $self->_validate($file);
}

sub _validate{
    my ($self, $file) = @_;
    my $image_type = Image::Info::image_type($file);

    if ( defined($image_type->{'file_type'}) ){
        return lc($image_type->{'file_type'});
    }

    return 0;
}

1;

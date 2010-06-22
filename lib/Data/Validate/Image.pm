package Data::Validate::Image;
use strict;
use warnings;

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

sub new {
    my $invocant = shift;

    my $class = ref($invocant) || $invocant;
    my $self = { };
    bless($self,$class);

    return $self;
}

sub is_image{
    my ($self, $file) = @_;

    return $self->_validate($file);
}

sub _validate{
    my ($self, $file) = @_;
    my $image_type = Image::Info::image_info($file);

    if ( defined($image_type->{'file_ext'}) ){
        my @frames = `convert -identify "${file}" /dev/null`;
        return {
            'x' => $image_type->{'width'},
            'y' => $image_type->{'height'},
            'size' => (-s $file) / 1024,
            'mime' => $image_type->{'file_media_type'},
            'file_ext' => $image_type->{'file_ext'},
            'animated' => (scalar(@frames) - 1),
        };
    }

    return 0;
}

1;

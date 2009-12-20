package Fetch::Image;

use strict;
use warnings;

use Moose;
use LWPx::ParanoidAgent;
use Data::Validate::Image;

=head1 NAME

Fetch::Image - Fetches an image

=head1 SYNOPSIS

stuff goes here

=head1 DESCRIPTION

Fetches an image from a remote webserver

=head2 EXPORTS

Exports nothing

=head1 SEE ALSO

L<Data::Validate::Image>, L<LWPx::ParanoidAgent>

=head1 AUTHORS

Copyright 2009 mrbig4545 at thisaintnews.com

=head1 LICENSE

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl v5.10.1 itself.

=cut

sub BUILD{
    my ($self, $config) = @_;

    $self->{'config'} = $config;
    return 1;
}

# fetch
# validte
# clean / move
#
sub fetch{
    my ($self, $url, $save_here) = @_;
    my $retval;

    my $ua = $self->setup_ua();
    my $head = $self->head($ua, $url);

    if ( $self->validate_head($head) ){
    #http response says image

        if ( my $tmp_file = $self->save_tmp($ua, $url) ){
        #tempory file saved

            if ( my $image_format = $self->is_image($tmp_file) ){
            #is image

                if ( $self->move_image($tmp_file, "${save_here}.${image_format}") ){
                #image upload complete

                } else {
                #save failed
                }

            } else {
            #not an image
            undef $tmp_file;
            }
        } else {
        #failed to save tmp file
        }
    } else {
        $retval = 'Not an image';
    }
}

#sets up the LWPx::ParanoidAgent
sub setup_ua{
    my ($self) = @_;
    my $ua = new LWPx::ParanoidAgent;

    $ua->agent($self->{'config'}->{'user_agent'}) if defined($self->{'config'}->{'user_agent'});
    $ua->timeout($self->{'config'}->{'timeout'}) if defined($self->{'config'}->{'timeout'});
    $ua->cookie_jar({});

    return $ua;
}

# returns a HTTP::Response for a HTTP HEAD request
sub head{
    my ($self, $ua, $url) = @_;

    return $ua->head($url);
}

sub content_type{
    my ($self, $content_type) = @_;

# *********
# this should be in COMPONENT!
# *********
    my $allowed_types;
    if ( defined($self->{'config'}->{'allowed_types'}) ){
        $allowed_types = $self->{'config'}->{'allowed_types'} 
    } else {
        $allowed_types = {
            'image/png' => 1,
            'image/jpg' => 1,
            'image/jpeg' => 1,
            'image/bmp' => 1,
            'image/gif' => 1,
        };
    }
# *******
# end
# *******

    if ( defined($allowed_types->{$content_type}) ){
        return 1;
    }

    return 0;
}

# checks HTTP:Response for image validity (error, format, size)
sub validate_head{
    my ($self, $head) = @_;

    if ( $head->is_error ){
    #some kind of http error
        return 0;
    }

    my $content_type = $self->content_type($head->header('content-type'));
    if ( !$content_type ){
    # not an image
        return 0;
    }

    if ( $head->header('content-length') > $self->{'config'}->{'max_filesize'} ){
    #file too big
        return 0;
    }

    return 1;
}

# returns a File::Temp copy of the requested url
sub save_tmp{
    my ($self, $ua, $url) = @_;

    # fetch file
    #  save to tmp file 
    #   use File::Temp
    #  validate image
    #   if invalid clean up
    #    return false
    # return $tmp_file

    1;
}

# returns filetype if File::Temp points to an image
sub is_image{
    my ($self, $tmp_file) = @_;

    # my $format = check if $tmp_file->filename is image
    # if fasle
    #   undef $tmp_file;
    #   return 0
    # return $format_lookup->{$format}

    1;
}

# moves the File::Temp and makes it permanent
sub move_image{
    my ($self, $tmp_file, $save_here) = @_;
    # image is clean
    #  save image
    #   return true/false

    1;
}

1;

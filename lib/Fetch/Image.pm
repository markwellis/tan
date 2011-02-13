package Fetch::Image;
use strict;
use warnings;

use LWPx::ParanoidAgent;
use Data::Validate::Image;
use Data::Validate::URI qw/is_web_uri/;
use File::Temp;

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

sub new{
    my ($invocant, $config) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = { };
    bless($self, $class);
    
    $self->{'image_validator'} = new Data::Validate::Image;

    $self->{'config'} = $config;

    # setup some defaults
    $self->{'config'}->{'max_filesize'} = 524_288 if ( !defined($self->{'config'}->{'max_filesize'}) );

    # default allowed image types if none defined
    if ( !defined($self->{'config'}->{'allowed_types'}) ){
        $self->{'config'}->{'allowed_types'} = {
            'image/png' => 1,
            'image/jpg' => 1,
            'image/jpeg' => 1,
            'image/pjpeg' => 1,
            'image/bmp' => 1,
            'image/gif' => 1,
        };
    }

    return $self;
}

sub fetch{
    my ( $self, $url ) = @_;

    if ( !defined($url) ){
        die "no url\n";
    } elsif  ( !defined(is_web_uri($url)) ){
        die "invalid url\n";
    }

    my $ua = $self->setup_ua($url);

    my $head = $self->head($ua, $url);
    return $self->save($ua, $url)
        || die "generic error\n";
}

#sets up the LWPx::ParanoidAgent
sub setup_ua{
    my ( $self, $url ) = @_;

    my $ua = new LWPx::ParanoidAgent;

    $ua->agent($self->{'config'}->{'user_agent'}) if defined($self->{'config'}->{'user_agent'});
    $ua->timeout($self->{'config'}->{'timeout'}) if defined($self->{'config'}->{'timeout'});
    $ua->cookie_jar({});

    $ua->default_header('Referer' => $url);

    return $ua;
}

# returns a HTTP::Response for a HTTP HEAD request
sub head{
    my ( $self, $ua, $url ) = @_;

    my $head = $ua->head($url);

    $head->is_error && die "transfer error\n";

    exists($self->{'config'}->{'allowed_types'}->{ $head->header('content-type') }) 
        || die "invalid content-type\n";

    if ( $head->header('content-length') && ($head->header('content-length') > $self->{'config'}->{'max_filesize'}) ){
    #file too big
        die "filesize exceeded\n";
    }

    return $head;
}

# returns a File::Temp copy of the requested url
sub save{
    my ($self, $ua, $url) = @_;

    my $response = $ua->get($url) || die "download Failed\n";

    my $temp_file = File::Temp->new() || die "temp file save failed\n";
    $temp_file->print($response->content);
    $temp_file->close;

    my $image_info = $self->{'image_validator'}->validate($temp_file->filename);

    if ( !$image_info ){
        $temp_file->DESTROY; 
        die "not an image\n";
    };

    $image_info->{'temp_file'} = $temp_file;
    return $image_info;
}

1;

package TAN::Controller::Profile::Avatar;
use strict;
use warnings;

#override namespace
__PACKAGE__->config(namespace => 'profile/_avatar');

use parent 'Catalyst::Controller';
use JSON;

my $int_reg = qr/\D+/;

=head1 NAME

TAN::Controller::Profile::Avatar

=head1 DESCRIPTION

Avatar upload pages

=head1 EXAMPLE

I</chat>

=head1 METHODS

=cut

=head2 index: Path()

B<@args = undef>

=over

loads chat template... 

=back

=cut

sub auto: Private{
    my ( $self, $c ) = @_;

    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/');
        $c->detach();
    }

    return 1;
}

sub index: Path{
    my ( $self, $c ) = @_;

    if ( $c->req->param('crop') ){
        $c->stash->{'crop'} = 1;
    }

    $c->stash->{'template'} = 'Profile::Avatar';
}

sub upload: Local{
    my ( $self, $c ) = @_;

    if (my $upload = $c->request->upload('avatar')) {
    #upload
        my $fileinfo = $c->model('ValidateImage')->is_image($upload->tempname);
        if( $fileinfo ){
        #is an image
            my @path = split('/', 'root/' . $c->config->{'avatar_path'} . '/' . $c->user->user_id . '.no_crop');

            $fileinfo->{'filename'} = $c->path_to(@path);

            if ( -e $fileinfo->{'filename'} ){
            #delete existing pre-crop
                unlink($fileinfo->{'filename'});
            }

            my $image = $c->model('Thumb')->resize($upload->tempname, $fileinfo->{'filename'}, 640);
            undef $upload;
            if ( !$image && -e $fileinfo->{'filename'} ){
            # upload success
#redirect back to avatar upload page
            
                $c->res->redirect('/profile/_avatar/?crop=true');
                $c->detach();
            } else {
                $c->flash->{'message'} = 'Upload Error';
                $c->res->redirect('/profile/_avatar');
                $c->detach();
            }
        } else {
            $c->flash->{'message'} = 'Not an image';
            $c->res->redirect('/profile/_avatar');
            $c->detach();
        }
    }

#shouldnt get ehre
    $c->flash->{'message'} = 'Upload Error';
    $c->res->redirect('/profile/_avatar');
    $c->detach();

}

sub crop: Local{
    my ( $self, $c ) = @_;

    my $json = $c->req->param('cords');

    if ( !$json ){
#ERROR HERE
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar?crop=true');
        $c->detach();
    }
    my $cords;
    
#errors if $json isnt json :|
    eval{
        $cords = from_json( $json );
    };

    if ( $@ || ref($cords) ne 'HASH' ){
#ERROR HERE
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar?crop=true');
        $c->detach();
    }

    my ($x, $y, $w, $h) = (
        $cords->{'x'},
        $cords->{'y'},
        $cords->{'w'},
        $cords->{'h'},
    );
    $x =~ s/$int_reg//g;
    $y =~ s/$int_reg//g;
    $w =~ s/$int_reg//g;
    $h =~ s/$int_reg//g;

#x, y can be 0,0!
    if ( !$w || !$h ){
#ERROR HERE
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar?crop=true');
        $c->detach();
    }

    my @path = split('/', 'root/' . $c->config->{'avatar_path'} . '/' . $c->user->user_id);
    my $filename = $c->path_to(@path);

    my $crop_res = $c->model('Thumb')->crop("${filename}.no_crop", $filename, $x, $y, $w, $h);

    if ( $crop_res ){
# SUCCESS
        $c->flash->{'message'} = 'Upload complete';

        if ( -e $filename . '.no_crop' ){
#        #delete pre-crop
            unlink( $filename . '.no_crop' );
        }

        $c->res->redirect('/profile/_avatar');
    } else {
#ERROR HERE
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar?crop=true');
    }
    
    $c->detach();
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

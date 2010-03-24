package TAN::Controller::Profile;
use strict;
use warnings;

use parent 'Catalyst::Controller';
use JSON;
=head1 NAME

TAN::Controller::Profile

=head1 DESCRIPTION

Profile page

=head1 EXAMPLE

I</chat>

=head1 METHODS

=cut

=head2 avatar: Path(avatar)

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

sub avatar: Local {
    my ( $self, $c ) = @_;

    if ( $c->req->param('crop') ){
        $c->stash->{'crop'} = 1;
    }

    $c->stash->{'template'} = 'profile/avatar.tt';
}

sub upload_avatar: Local{
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
            if ( !$image && -e $fileinfo->{'filename'} ){
            # upload success
#redirect back to avatar upload page
            
                $c->res->redirect('/profile/avatar?crop=true');
                $c->detach();
            } else {
                $c->flash->{'error'} = 'Upload Error';
                $c->res->redirect('/profile/avatar');
                $c->detach();
            }

            undef $upload;
        } else {
            $c->flash->{'error'} = 'Not an image';
            $c->res->redirect('/profile/avatar');
            $c->detach();
        }
    }

#shouldnt get ehre
    $c->flash->{'error'} = 'Upload Error';
    $c->res->redirect('/profile/avatar');
    $c->detach();

}

sub crop_avatar: Local{
    my ( $self, $c ) = @_;

    my $json = $c->req->param('cords');

    if ( !defined($json) ){
#ERROR HERE
        $c->detach();
    }
    my $cords = from_json( $json );
    use Data::Dumper;

    warn Dumper $cords; 
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

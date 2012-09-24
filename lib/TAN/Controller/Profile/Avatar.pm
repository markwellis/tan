package TAN::Controller::Profile::Avatar;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

#override namespace
__PACKAGE__->config(namespace => 'profile/_avatar');

use JSON;
use Try::Tiny;

sub auto: Private{
    my ( $self, $c ) = @_;

    if ( !$c->user_exists ){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/', 303);
        $c->detach();
    }

    return 1;
}

sub index: Path{
    my ( $self, $c ) = @_;

    if ( $c->req->param('crop') ){
        $c->stash->{'crop'} = 1;
    }

    $c->stash(
        'template' => 'profile/avatar.tt',
        'page_title' => 'Change avatar',
    );
}

sub upload: Local{
    my ( $self, $c ) = @_;

    if ( my $upload = $c->request->upload('avatar') ){
        #upload
        try{
            my @outfile_path = split('/', "root/@{[ $c->config->{'avatar_path'} ]}/@{[ $c->user->user_id ]}.no_crop");
            my $outfile = $c->path_to( @outfile_path );

            if ( -e $outfile ){
            #delete existing pre-crop
                unlink( $outfile );
            }

            try{
                $c->model('Image')->thumbnail( $upload->tempname, $outfile, 640 );
            } catch {
                $c->flash->{'message'} = $_->error;
                $c->res->redirect('/profile/_avatar', 303);
            };
            undef $upload;

            # upload success
            #redirect back to avatar upload page
            $c->res->redirect('/profile/_avatar/?crop=true', 303);
        }catch{
            $c->flash->{'message'} = $_->error;
            $c->res->redirect('/profile/_avatar', 303);
        };
    } else {
        $c->flash->{'message'} = 'no image uploaded';
        $c->res->redirect('/profile/_avatar/', 303);
    }
    $c->detach();
}

sub crop: Local{
    my ( $self, $c ) = @_;

    my $json = $c->req->param('cords');

    if ( !$json ){
#ERROR HERE
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar/?crop=true', 303);
        $c->detach();
    }
    my $cords;
    
#errors if $json isnt json :|
    $cords = try{
        return from_json( $json );
    } catch {
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar/?crop=true', 303);
        $c->detach();
    };

    my ($x, $y, $w, $h) = (
        $cords->{'x'},
        $cords->{'y'},
        $cords->{'w'},
        $cords->{'h'},
    );

    my $not_int_reg = $c->model('CommonRegex')->not_int;

    $x =~ s/$not_int_reg//g;
    $y =~ s/$not_int_reg//g;
    $w =~ s/$not_int_reg//g;
    $h =~ s/$not_int_reg//g;

#x, y can be 0,0!
    if ( !$w || !$h ){
#ERROR HERE
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar?crop=true', 303);
        $c->detach();
    }

    my @path = split('/', 'root/' . $c->config->{'avatar_path'} . '/' . $c->user->user_id);
    my $filename = $c->path_to(@path);

    my $crop_res = $c->model('Image')->crop("${filename}.no_crop", $filename, $x, $y, $w, $h);

    if ( $crop_res ){
# SUCCESS
        $c->flash->{'message'} = 'Upload complete';

        if ( -e $filename . '.no_crop' ){
#        #delete pre-crop
            unlink( $filename . '.no_crop' );
        }

        $c->res->redirect('/profile/_avatar/', 303);
    } else {
#ERROR HERE
        $c->flash->{'message'} = 'Crop error';
        $c->res->redirect('/profile/_avatar/?crop=true', 303);
    }
    
    $c->detach();
}

__PACKAGE__->meta->make_immutable;

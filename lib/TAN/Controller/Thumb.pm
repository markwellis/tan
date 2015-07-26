package TAN::Controller::Thumb;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub index: Path Args(3) {
    my ( $self, $c, $mod, $id, $x ) = @_;

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $id =~ s/$not_int_reg//g;
    $x =~ s/$not_int_reg//g;

    if ( !$x || !$id ){
        $c->detach('/default');
    }

    #work out mod incase someone ddoses server by requesting random mods :\
    if ( $mod != ( $id - ( $id % 1000 ) ) ){
        $mod = $id - ( $id % 1000 );
        $c->res->redirect( $c->config->{'thumb_path'} . "/${mod}/${id}/${x}", 303 );
        $c->detach;
    }

    my $picture = $c->model('DB::Picture')->find({
        'picture_id' => $id,
    });

    if ( !$picture ){
        $c->detach('/default');
    }

    my $source_image = $c->path_to('root') . $c->config->{'pic_path'} . "/" . $picture->filename;
    my $output_image = $c->path_to('root') . $c->config->{'thumb_path'} . "/${mod}/${id}/${x}";

    try{
        $c->model('Image')->thumbnail( $source_image, $output_image, $x );
    } catch {
        $c->model('Image')->create_blank( $output_image );
    };

    $c->res->redirect( $c->config->{'thumb_path'} . "/${mod}/${id}/${x}?" . int(rand(100)), 303 );
    $c->detach;
}

__PACKAGE__->meta->make_immutable;

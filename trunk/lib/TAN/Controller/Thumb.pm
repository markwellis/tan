package TAN::Controller::Thumb;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use File::Path qw/mkpath/;
use Try::Tiny;

sub index: Path Args(3) {
    my ( $self, $c, $mod, $id, $x ) = @_;

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $id =~ s/$not_int_reg//g;
    $x =~ s/$not_int_reg//g;

    #work out mod incase someone ddoses server by requesting random mods :\
    $mod = $id - ($id % 1000);

    if ($x != 100 && $x != 150 && $x != 160 && $x != 200 && $x != 250 && $x != 300 && $x != 400 && $x != 500 && $x != 600){
        $c->forward('/default');
        $c->detach();
    }

    # if thumb resize works properly, then we'll be redirected back to this page
    # with a time param, just to make sure we don't hit a cache
    $c->forward('resize', [$mod, $id, $x]);
    $c->forward('/default');
    $c->detach();
}

sub resize: Private {
    my ( $self, $c, $mod, $id, $x ) = @_;

    my $row = $c->model('MySQL::Picture')->find({
        'picture_id' => $id,
    });

    #def this here coz we might need it if the image dont exist
    my $cache_image = $c->path_to('root') . $c->config->{'thumb_path'} . "/${mod}/${id}";
    mkpath($cache_image);
    $cache_image .= "/${x}";

    if ( defined($row) && (my $filename = $row->filename) ){
        my $orig_image = $c->path_to('root') . $c->config->{'pic_path'} . "/${filename}";

        my $image = try{
            $c->model('Image')->resize($orig_image, $cache_image, $x);
        } catch {
            $c->forward( 'copy_blank', [ $cache_image, $mod, $id, $x ] );
        };
        if ( !$image && -e $cache_image ){
            $c->res->redirect("/static/cache/thumbs/${mod}/${id}/${x}?" . int(rand(100)), 303);
            $c->detach();
        }
    }
    #if we get here somethings gone wrong
    $c->forward( 'copy_blank', [ $cache_image, $mod, $id, $x ] );
}

sub copy_blank: Private{
    my ( $self, $c, $cache_image, $mod, $id, $x ) = @_;

    my $cp_command = 'cp ' . $c->path_to(qw/root static images blank.png/) . " ${cache_image}";
    `${cp_command}`;
    $c->res->redirect("/static/cache/thumbs/${mod}/${id}/${x}?" . int(rand(100)), 303);
    $c->detach();
}

__PACKAGE__->meta->make_immutable;

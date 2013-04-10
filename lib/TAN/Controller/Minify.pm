package TAN::Controller::Minify;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use File::Path qw/rmtree/;
use Fcntl qw/:flock/;

sub index: Path{
    my ( $self, $c, $version, $theme, $type, @file_list ) = @_;

    if ( $version ne $c->VERSION ){
        $c->detach('e404');
    }
    
    if ( $type !~ m/^(?:css|js)$/ ){
        $c->detach('e404');
    }

    my $format = qr/^[a-zA-Z0-9\-]+(?:\.css|\.js)?$/;
    my @files;
    foreach my $file ( @file_list ){
        if ( $file =~ /$format/ ){
            push( @files, $file );
        }
    }
    my $file = join( '/', @files );

    my $source_dir = $c->path_to('root', $c->config->{'static_path'}, 'themes', $theme, $type);

    if ( ! -e "${source_dir}/${file}" ){
        $c->detach('e404');
    }

    my $out_dir = $c->path_to('root') . $c->config->{'cache_path'} . '/minify/' . $c->VERSION . "/${theme}/${type}";
    #/static/cache/minify/4.1.04/mobile/css/shared.css

    my $text = $c->model('Minify')->minify(
        $type, 
        "${source_dir}/${file}", 
        "${out_dir}/${file}"
    );
    
    if ( $text ){
        if ( $type eq 'css' ) {
            $c->res->header('Content-Type' => 'text/css');
        } elsif ( $type eq 'js' ){
            $c->res->header('Content-Type' => 'application/x-javascript');
        }
        $c->response->body( $text );
    
        #remove old files
        my $version_dir = $c->path_to('root') . $c->config->{'cache_path'} . '/minify';
        foreach my $version_cache ( <$version_dir/*> ){
            if ( $version_cache ne "${version_dir}/" . $c->VERSION ){
                open( my $fh, ">", '/tmp/tan_old_js_clean' ) || die "failed to open /tmp/tan_old_js_clean' $!";
                if ( flock( $fh, LOCK_EX | LOCK_NB ) ){
                    rmtree( $version_cache );
                    flock( $fh, LOCK_UN );
                }
                close( $fh );
                unlink( '/tmp/tan_old_js_clean' ) || die "failed to unlink '/tmp/tan_old_js_clean' $!";
            }
        }

        $c->detach;
    }
    
    $c->detach('e404');
}

sub e404: Private{
    my ( $self, $c ) = @_;
    
    $c->response->status(404);
    $c->response->body('404 not found');
    $c->detach;
}

__PACKAGE__->meta->make_immutable;

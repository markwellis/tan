package TAN::Controller::Minify;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use File::Path qw/rmtree/;

sub version_check: PathPart('minify') Chained('/') CaptureArgs(3){
    my ( $self, $c, $version, $theme, $type ) = @_;

    if ( $version ne $c->VERSION ){
        $c->detach('/default');
    }
    
    if ( $type !~ m/^(?:css|js)$/ ){
        $c->detach('/default');
    }

    $c->stash(
        'theme' => $theme,
        'type' => $type,
    );

    #remove old files
    my $version_dir = $c->path_to('root') . $c->config->{'cache_path'} . '/minify';
    foreach my $version ( <$version_dir/*> ){
        if ( $version ne "${version_dir}/" . $c->VERSION ){
            rmtree( $version );
        }
    }
}

sub minify: PathPart('') Chained('version_check'){
    my ( $self, $c, @file_list ) = @_;

    my $type = $c->stash->{'type'};

    my $format = qr/^[a-zA-Z0-9\-]+(?:\.css|\.js)$/;
    my @files;
    foreach my $file ( @file_list ){
        if ( $file =~ /$format/ ){
            push( @files, $file );
        }
    }
    my $file = join( '/', @files );
    my $source_dir = $c->path_to('root', $c->config->{'static_path'}, 'themes', $c->stash->{'theme'}, $type);

    if ( ! -e "${source_dir}/${file}" ){
        $c->detach('/default');
    }

    my $out_dir = $c->path_to('root') . $c->config->{'cache_path'} . '/minify/' . $c->VERSION . '/' . $c->stash->{'theme'} . "/${type}";
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
        $c->detach;
    }
    
    $c->detach('/default');
}

__PACKAGE__->meta->make_immutable;

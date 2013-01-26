package TAN::Model::Minify;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use JavaScript::Minifier::XS;
use CSS::Minifier::XS;
use File::Basename;
use File::Path qw/mkpath/;

sub minify{
    my ( $self, $type, $input, $output ) = @_;
    my $text;

    if (-e $output){
        # use cached file if avaible, really though, this should be handled in the webserver
        # but its a good fall back incase something goes wrong.

        open( my $input_fh, $output ) || die "failed to open '${output}' for read error: '${!}'";

        while (my $line = <$input_fh>) {
            $text .= $line;
        }

        close( $input_fh );
    } elsif (-e $input){
        open( my $input_fh , "< ${input}" ) || die "failed to open '${input}' for read error: '${!}'";

        my $output_fh;
        if ( !$ENV{'CATALYST_DEBUG'} ){
            mkpath( dirname( $output ) );
            open( $output_fh, "> ${output}") || die "failed to opne '${output}' for write error: '${!}'";
        }
        
        while ( my $line = <$input_fh> ){
            $text .= $line;
        }

        if ( !$ENV{'CATALYST_DEBUG'} ){
        #disable minify for dev mode
            if ( $type eq 'css' ){
                $text = CSS::Minifier::XS::minify($text);
            } elsif ( $type eq 'js' ){
                $text = JavaScript::Minifier::XS::minify($text);
            }

            print $output_fh $text;
        }

        close( $input_fh );
        if ( !$ENV{'CATALYST_DEBUG'} ){
            close( $output_fh );
        }
    }

    return $text;
}

__PACKAGE__->meta->make_immutable;

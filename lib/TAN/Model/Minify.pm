package TAN::Model::Minify;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use JavaScript::Minifier::XS;
use CSS::Minifier::XS;
use File::Basename;
use File::Path qw/mkpath/;

sub minify{
    my ($self, $type, $input, $output) = @_;
    my $text;

    if (-e $output){
        # use cached file if avaible, really though, this should be handled in the webserver
        # but its a good fall back incase something goes wrong.

        open(INPUT, $output);

        while (my $line = <INPUT>) {
            $text .= $line;
        }
    } elsif (-e $input){


        open(INPUT, "< ${input}");
        if ( !$ENV{'CATALYST_DEBUG'} ){
            mkpath( dirname( $output ) );
            open(OUTPUT, "> ${output}");
        }
        
        while (my $line = <INPUT>) {
            $text .= $line;
        }

        if ( !$ENV{'CATALYST_DEBUG'} ){
        #disable minify for dev mode
            if ( $type eq 'css' ){
                $text = CSS::Minifier::XS::minify($text);
            } elsif ( $type eq 'js' ){
                $text = JavaScript::Minifier::XS::minify($text);
            }

            print OUTPUT $text;
        }

        close(INPUT);
        if ( !$ENV{'CATALYST_DEBUG'} ){
            close(OUTPUT);
        }
    }

    return $text;
}

__PACKAGE__->meta->make_immutable;

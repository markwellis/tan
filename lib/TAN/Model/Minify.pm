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

        mkpath( dirname( $output ) );

        open(INPUT, "< ${input}");
        open(OUTPUT, "> ${output}");
        
        while (my $line = <INPUT>) {
            $text .= $line;
        }

        if ( $type eq 'css' ){
            $text = CSS::Minifier::XS::minify($text);
        } elsif ( $type eq 'js' ){
            $text = JavaScript::Minifier::XS::minify($text);
        }

        print OUTPUT $text;

        close(INPUT);
        close(OUTPUT);
    }

    return $text;
}

__PACKAGE__->meta->make_immutable;

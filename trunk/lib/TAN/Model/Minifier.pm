package TAN::Model::Minifier;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use JavaScript::Minifier::XS;
use CSS::Minifier::XS;

sub minify{
    my ($self, $type, $infile, $outfile) = @_;
    my $text;

    if (-e $outfile){
        # use cached file if avaible, really though, this should be handled in the webserver
        # but its a good fall back incase something goes wrong.

        open(INFILE, $outfile);

        while (my $line = <INFILE>) {
            $text .= $line;
        }
    } elsif (-e $infile){
        open(INFILE, "< ${infile}");
        open(OUTFILE, "> ${outfile}");
        
        while (my $line = <INFILE>) {
            $text .= $line;
        }

        if ( $type eq 'css' ){
            $text = CSS::Minifier::XS::minify($text);
        } elsif ( $type eq 'js' ){
            $text = JavaScript::Minifier::XS::minify($text);
        }

        print OUTFILE $text;

        close(INFILE);
        close(OUTFILE);
    }

    return $text;
}

__PACKAGE__->meta->make_immutable;

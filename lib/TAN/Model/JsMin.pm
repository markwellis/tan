package TAN::Model::JsMin;

use strict;
use warnings;
use parent 'Catalyst::Model';

use JavaScript::Minifier::XS;

sub minify_file{
    my ($self, $infile, $outfile) = @_;
    my $js;

    if (-e $outfile){
        # use cached file if avaible, really though, this should be handled in the webserver
        # but its a good fall back incase something goes wrong.

        open(INFILE, $outfile);

        while (my $line = <INFILE>) {
            $js .= $line;
        }
    } elsif (-e $infile){
        open(INFILE, "< ${infile}");
        open(OUTFILE, "> ${outfile}");
        
        while (my $line = <INFILE>) {
            $js .= $line;
        }

        $js = JavaScript::Minifier::XS::minify($js);

        print OUTFILE $js;

        close(INFILE);
        close(OUTFILE);
    }

    return $js;
}

=head1 NAME

TAN::Model::JsMin - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

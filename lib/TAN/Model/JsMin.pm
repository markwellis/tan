package TAN::Model::JsMin;

use strict;
use warnings;
use parent 'Catalyst::Model';

use JavaScript::Minifier::XS;

=head1 NAME

TAN::Model::JsMin

=head1 DESCRIPTION

Minifies js and caches it

=head1 METHODS

=cut

=head2 minify_file

B<@args = ($infile, $outfile)>

=over

minifies $infile and returns & caches it in $outfile

=back

=cut
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

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

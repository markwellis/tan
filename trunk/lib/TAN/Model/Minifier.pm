package TAN::Model::Minifier;

use strict;
use warnings;
use parent 'Catalyst::Model';

use JavaScript::Minifier::XS;
use CSS::Minifier::XS;

=head1 NAME

TAN::Model::Minifier

=head1 DESCRIPTION

Minifies css or js and caches it

=head1 METHODS

=cut

=head2 minify

B<@args = ($type, $infile, $outfile)>

=over

minifies $infile of $type and writes to $outfile

=back

=cut
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

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

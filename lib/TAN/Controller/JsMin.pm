package TAN::Controller::JsMin;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use JavaScript::Minifier::XS qw(minify);
use File::Path;

=head2 index

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $source_file ) = @_;

    $source_file =~ s/[^a-z0-9\-\_]//g;
    my $out_file = $source_file;
    
    $out_file =~ s/js$/\.js/;
    $source_file =~ s/.*_(.*)_.*/$1\.js/;

    my $source_dir = $c->path_to('root', $c->config->{'static_path'}, 'themes', $c->stash->{'theme_settings'}->{'name'}, 'js');
    
    my $theme_path = $c->config->{'cache_path'} . '/jsmin/' . $c->stash->{'theme_settings'}->{'name'};
    
    my $out_dir = $c->path_to('root', $c->config->{'static_path'}) . $theme_path;

    if (-e "${out_dir}_${out_file}"){
        open(INFILE, "< ${out_dir}_${out_file}");

        my $js; 
        while (my $line = <INFILE>) {
            $js .= $line;
        }
        $c->response->body($js);
        $c->detach();        
    } elsif (-e "${source_dir}/${source_file}"){
        open(INFILE, "< ${source_dir}/${source_file}");
        open(OUTFILE, "> ${out_dir}_${out_file}");
        
        my $js; 
        while (my $line = <INFILE>) {
            $js .= $line;
        }
        $js = minify($js);
        print OUTFILE $js;
        
        close(INFILE);
        close(OUTFILE);
        
        $c->response->body($js);
        $c->detach();
    }
    
    $c->forward('/default');
    $c->detach();
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

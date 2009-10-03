package TAN::Controller::JsMin;

use strict;
use warnings;
use parent 'Catalyst::Controller';


=head2 index

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $source_file ) = @_;

    $source_file =~ s/[^a-z0-9\-\_]//g;
    my $out_file = $source_file;
    
    $out_file =~ s/js$/\.js/;
    $source_file =~ s/.*_(.*)_.*/$1\.js/;

    my $source_dir = $c->path_to('root', $c->config->{'static_path'}, 'themes', $c->stash->{'theme_settings'}->{'name'}, 'js');
    
    my $theme_path = $c->config->{'jscache_path'};
    
    my $out_dir = $c->path_to('root') . $theme_path;

warn "${source_dir}/${source_file}\n${out_dir}/${out_file}\n";

    my $js = $c->model('JsMin')->minify_file("${source_dir}/${source_file}", "${out_dir}/${out_file}");

    if ($js){
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

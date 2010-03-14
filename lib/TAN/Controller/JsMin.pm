package TAN::Controller::JsMin;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::JsMin

=head1 DESCRIPTION

Minifies js and caches it

Webserver rule means should only be called if cache doesn't exist in the filesystem already

=head1 EXAMPLE

I</static/cache/js/$theme_$file_$mtime.js>

=over

outside world access url (configurable)

=over

$theme => theme name

$file  => filename

$mtime => filemtime

=back

=back

I</jsmin/$theme_$file_$mtime.js>

=over

Webserver internal redirect url

=back

=head1 METHODS

=cut

=head2 index: Path: Args(1)

B<@args = ($source_file)>

=over

splits $source_file into $theme, $file, $mtime

uses JsMin model to minify js

outputs js or 404's

=back

=cut
my $alpha_reg = qr/[^a-zA-Z0-9\-_]/; 
my $format_reg = qr/\w+_(.*)_\w+/;
my $ext_reg = qr/js$/;

sub index: Path('/static/cache/js/') Args(1) {
    my ( $self, $c, $source_file ) = @_;

    $source_file =~ s/$alpha_reg//g;
    
    if ($source_file !~ m/$format_reg/){
        $c->forward('/default');
        $c->detach();
    }

#this looks like some complex shit that needs some proper comments
    my $out_file = $source_file;
    
    $out_file =~ s/$ext_reg/\.js/;
    $source_file =~ s/$format_reg/$1\.js/;

    my $source_dir = $c->path_to('root', $c->config->{'static_path'}, 'themes', $c->stash->{'theme_settings'}->{'name'}, 'js');
    my $theme_path = $c->config->{'jscache_path'};
    my $out_dir = $c->path_to('root') . $theme_path;

    my $js = $c->model('JsMin')->minify_file("${source_dir}/${source_file}", "${out_dir}/${out_file}");

    if ($js){
        $c->res->header('Content-Type' => 'application/x-javascript');
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

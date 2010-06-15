package TAN::Controller::Minifier;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Minifier

=head1 DESCRIPTION

Minifies css or js and caches it

Webserver rule means should only be called if cache doesn't exist in the filesystem already

=head1 EXAMPLE

I</static/cache/js/$theme_$file_$mtime.js>
I</static/cache/css/$theme_$file_$mtime.css>

=over

outside world access url (configurable)

=over

$theme => theme name

$file  => filename

$mtime => filemtime

=back

=back

I</minifier/$theme_$file_$mtime.js>
I</minifier/$theme_$file_$mtime.css>

=over

Webserver internal redirect url

=back

=head1 METHODS

=cut

=head2 index: Path: Args(1)

B<@args = ($source_file)>

=over

splits $source_file into $theme, $file, $mtime

uses Minifer model to minify css/js

outputs css/js or 404's

=back

=cut
my $alpha_reg = qr/[^a-zA-Z0-9\-_@]/; 
my $format_reg = qr/[a-zA-Z0-9\-@]+_(.*)_\w+/;
my $ext_reg = qr/(css|js)$/;

sub index: Path Args(1) {
    my ( $self, $c, $source_file ) = @_;

    $source_file =~ s/$alpha_reg//g;

    if ($source_file !~ m/$format_reg/){
        $c->forward('/default');
        $c->detach();
    }

#this looks like some complex shit that needs some proper comments
    my $out_file = $source_file;

# figure out if css or js from extension
    if ( $out_file =~ s/$ext_reg/\.$1/ ){
        my $type = $1;
        $source_file =~ s/$format_reg/$1\.$type/;

    #replace @ with / for dirs
        $source_file =~ s|@|/|g;

        my $source_dir = $c->path_to('root', $c->config->{'static_path'}, 'themes', $c->stash->{'theme_settings'}->{'name'}, $type);
        my $theme_path;
        if ( $type eq 'css' ){
            $theme_path = $c->config->{'csscache_path'};
        } elsif ( $type eq 'js' ){
            $theme_path = $c->config->{'jscache_path'};
        }
        my $out_dir = $c->path_to('root') . $theme_path;

        my $text = $c->model('Minifier')->minify($type, "${source_dir}/${source_file}", "${out_dir}/${out_file}");

        if ($text){
            if ( $type eq 'css' ) {
                $c->res->header('Content-Type' => 'text/css');
            } elsif ( $type eq 'js' ){
                $c->res->header('Content-Type' => 'application/x-javascript');
            }
            $c->response->body($text);
            $c->detach();
        }
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

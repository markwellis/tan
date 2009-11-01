package TAN::Controller::Thumb;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use File::Path;

=head1 NAME

TAN::Controller::Thumb - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut
my $int = qr/\D+/;

sub index :Path :Args(2) {
    my ( $self, $c, $id, $x ) = @_;
    
    $id =~ s/$int//g;
    $x =~ s/$int//g;

    my $row = $c->model('MySQL::Pictures')->find({
        'id' => $id,        
    });

    if ( defined($row) && (my $filename = $row->filename()) ){
        my $orig_image = $c->path_to('root') . $c->config->{'pic_path'} . "/${filename}";
        my $cache_image = $c->path_to('root') . $c->config->{'thumb_path'} . "/${id}";
        mkpath($cache_image);
        $cache_image .= "/${x}";

        my $image = $c->model('Thumb')->resize($orig_image, $cache_image, $x);
        if ($image){
            $c->response->headers->header('Content-Type' => 'image/jpeg');
            $c->response->body($image);
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

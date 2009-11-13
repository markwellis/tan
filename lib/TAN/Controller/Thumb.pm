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

    if ($x != 100 && $x != 150 && $x != 160 && $x != 200 && $x != 250 && $x != 300 && $x != 400 && $x != 500 && $x != 600){
        $c->forward('/default');
        $c->detach();
    }

    my $row = $c->model('MySQL::Picture')->find({
        'picture_id' => $id,
    });
    
    my $filename = $row->filename;

    if ( defined($row) && $filename ){
        my $orig_image = $c->path_to('root') . $c->config->{'pic_path'} . "/${filename}";
        my $cache_image = $c->path_to('root') . $c->config->{'thumb_path'} . "/${id}";
        mkpath($cache_image);
        $cache_image .= "/${x}";

        my $image = $c->model('Thumb')->resize($orig_image, $cache_image, $x);
        if (!$image){
            $c->res->redirect("/static/cache/thumbs/${id}/${x}");
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

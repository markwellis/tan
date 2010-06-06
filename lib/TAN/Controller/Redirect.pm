package TAN::Controller::Redirect;
use strict;
use warnings;

use parent 'Catalyst::Controller';
my $not_int_reg = qr/\D+/;
my $is_int_reg = qr/\d+/;

=head1 NAME

TAN::Controller::Redirect

=head1 DESCRIPTION

redirects to a objects url

=head1 EXAMPLE

I</redirect/internal/45990>
I</redirect/internal/23400/234234_sdfsdf.jpg>
I</redirect/external/45990>
I</redirect/old/$type/$id>

=head1 METHODS

=cut

=head2 internal: Local

B<@args = $source, $filename>

=over

for images. accepts id or filename and redirects to object url

=back

=cut
sub internal: Local{
    my ( $self, $c, $source, $filename ) = @_;

    my $url;
    if ( !defined($filename) && ($source =~ m/^$is_int_reg$/) ){
    #id
        my $object = $c->model('MySQL::Object')->find({
            'object_id' => $source,
        });

        if ( $object ){
            $url = $object->url;
        }
    } else {
    #filename
        if ( !defined($filename) ){
        #old filename (no mod)
            $source =~ /^(\d+)/;
            my $pic_time = $1;
            $filename = $source;
            $source = ($pic_time - ($pic_time % 604800));
        }
        my $picture = $c->model('MySQL::Picture')->find({
            'filename' => "${source}/${filename}",
        });

        if ( $picture ){
            $url = $picture->object->url;
        }
    }

    if ( $url ){
        $c->res->redirect($url);
    } else {
        $c->forward('/default');
    }
    $c->detach();
}

=head2 external: Local Args(1)

B<@args = object_id>

=over

redirects to object url 

=back

=cut
sub external: Local Args(1){
    my ( $self, $c, $object_id ) = @_;

    if ( !$object_id ){
        $c->forward('/default');
        $c->detach;
    }

    $object_id =~ s/$not_int_reg//g;

    my $object_rs = $c->model('MySQL::Object')->find($object_id);
    if ( defined($object_rs) && ($object_rs->type eq 'link') ){
    #links have urls
        my $session_id = $c->sessionid;
        my $ip_address = $c->req->address;

        if ( $object_id  && $session_id ){
            my $user_id = $c->user_exists ? $c->user->user_id : 0;

            $c->model('MySQL::Views')->update_or_create({
                'session_id' => $session_id,
                'object_id' => $object_id,
                'user_id' => $user_id,
                'ip' => $ip_address,
                'created' => \'NOW()',
                'type' => 'external',
            },{
                'key' => 'session_objectid',
            });
        }
        $c->res->redirect( $object_rs->link->url );
    } else {
    # not a link
        $c->forward('/default');
    }
    $c->detach();
}

=head2 old: Path Args(2)

B<@args = $type, $old_id>

=over

redirects to internal object url 

=back

=cut
sub old:Local Args(2){
    my ( $self, $c, $type, $old_id ) = @_;

    if ( $type eq 'pic' ){
    #consistancy ftw...
        $type = 'picture';
    }
    my $lookup = $c->model('MySQL::OldLookup')->find({
        'type' => $type,
        'old_id' => $old_id,
    });

    if ( defined($lookup) ){
        my $object = $c->model('MySQL::Object')->find({
            'object_id' => $lookup->new_id,
        });

        $c->res->redirect($object->url, 301);
        $c->detach();
    }

    $c->forward('/default');
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

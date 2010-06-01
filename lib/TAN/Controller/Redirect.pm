package TAN::Controller::Redirect;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Redirect

=head1 DESCRIPTION

redirects to a objects url

=head1 EXAMPLE

I</redirect/external/45990>
I</redirect/old/$type/$id>

=head1 METHODS

=cut

=head2 index: Path

B<@args = object_id>

=over

redirects to object url 

=back

=cut
my $int_reg = qr/\D+/;
sub external: Local{
    my ( $self, $c, $object_id ) = @_;

    if ( !$object_id ){
        $c->res->redirect('/');
        $c->detach;
    }

    $object_id =~ s/$int_reg//g;

    my $object_rs = $c->model('MySQL::Object')->find($object_id);
    my $url;
    if ( defined($object_rs) && ($object_rs->type eq 'link') ){
    #links have urls
        $url = $object_rs->link->url;

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
    } else {
    # not a link
        $url = '/';
    }
    $c->res->redirect( $url );
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

        $c->res->redirect( "/view/" . $object->type . "/" . $object->id . "/" . $object->url_title, 301);
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

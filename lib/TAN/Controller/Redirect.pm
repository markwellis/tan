package TAN::Controller::Redirect;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

#redirects from static image to object, for leach protection
sub internal: Local{
    my ( $self, $c, $source, $filename ) = @_;

    my $url;
    if ( defined($source) ){
        my $is_int_reg = $c->model('CommonRegex')->int;
        if ( !defined($filename) && ($source =~ m/^$is_int_reg$/) ){
        #id
            my $object = $c->model('DB::Object')->find({
                'object_id' => $source,
            });

            if ( $object ){
                $url = $object->url;
            }
        } else {
        #filename
            if ( !defined($filename) ){
            #old filename (no mod)
                $source =~ /^($is_int_reg)/;
                my $pic_time = $1;
                $filename = $source;
                $source = ($pic_time - ($pic_time % 604800));
            }
            my $picture = $c->model('DB::Picture')->find({
                'filename' => "${source}/${filename}",
            });

            if ( $picture && $picture->object ){
                $url = $picture->object->url;
            }
        }
    }

    if ( $url ){
        $c->res->redirect( $url, 303 );
    } else {
        $c->forward('/default');
    }
    $c->detach();
}

sub external: Local Args(1){
    my ( $self, $c, $object_id ) = @_;

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $object_id =~ s/$not_int_reg//g;

    if ( !$object_id ){
        $c->detach('/not_found');
    }

    my $object = $c->model('DB::Object')->find($object_id);
    if (
        !defined($object)
        || ($object->type ne 'link' && $object->type ne 'video')
    ){
    # not a link
        $c->detach('/not_found');
    }

    if ( $object->deleted ){
        $c->detach('/gone');
    }

    #links or videos have urls
    my $session_id = $c->sessionid;
    my $ip_address = $c->req->address;

    my $user_id = $c->user_exists ? $c->user->user_id : undef;

    eval{
    #might get a deadlock [358] - ignore in that case
        $c->model('DB::Views')->update_or_create({
            'session_id' => $session_id,
            'object_id' => $object_id,
            'user_id' => $user_id,
            'ip' => $ip_address,
            'created' => \'NOW()',
            'type' => 'external',
        },{
            'key' => 'session_objectid',
        });
    };

    my $type = $object->type;
    $c->res->redirect( $object->$type->url, 303 );

    $c->detach;
}

__PACKAGE__->meta->make_immutable;

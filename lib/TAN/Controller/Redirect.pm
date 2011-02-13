package TAN::Controller::Redirect;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub internal: Local{
    my ( $self, $c, $source, $filename ) = @_;

    my $url;
    if ( defined($source) ){
        my $is_int_reg = $c->model('CommonRegex')->int;
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
                $source =~ /^($is_int_reg)/;
                my $pic_time = $1;
                $filename = $source;
                $source = ($pic_time - ($pic_time % 604800));
            }
            my $picture = $c->model('MySQL::Picture')->find({
                'filename' => "${source}/${filename}",
            });

            if ( $picture && $picture->object ){
                $url = $picture->object->url;
            }
        }
    }

    if ( $url ){
        $c->res->redirect($url);
    } else {
        $c->forward('/default');
    }
    $c->detach();
}

sub external: Local Args(1){
    my ( $self, $c, $object_id ) = @_;

    if ( !$object_id ){
        $c->forward('/default');
        $c->detach;
    }

    my $not_int_reg = $c->model('CommonRegex')->not_int;
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

sub old_image: Local{
    my ( $self, $c, $source, $size ) = @_;

    my $url;
    if ( defined($source) ){
        my $is_int_reg = $c->model('CommonRegex')->int;
        if ( defined($size) && ($source =~ m/^$is_int_reg$/) ){
        #thumb
            my $lookup = $c->model('MySQL::OldLookup')->find({
                'type' => 'picture',
                'old_id' => $source,
            });
            if ( $lookup ){
                my $new_id = $lookup->new_id;
                my $mod = $new_id - ($new_id % 1000);
                $url = $c->config->{'thumb_path'} . "/${mod}/${new_id}/${size}";
            }
        } else {
        #filename
            #old filename (no mod)
            if ( $source =~ /^(\d+)/ ){
                my $pic_time = $1;
                my $mod = ($pic_time - ($pic_time % 604800));

                $url = $c->config->{'pic_path'} . "/${mod}/${source}";
            }
        }
    }

    if ( $url ){
        $c->res->redirect($url, 301);
    } else {
        $c->forward('/default');
    }
    $c->detach();
}

__PACKAGE__->meta->make_immutable;

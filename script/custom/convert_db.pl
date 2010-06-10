use strict;
use warnings;

use lib '../../lib';
use TAN::Model::MySQL;
use TAN::Model::OldDB;

use HTML::Entities;
use File::Basename;
use File::Copy;
use File::Path qw/mkpath/;
use Digest::SHA;

use Time::HiRes qw/time/;
use Term::ProgressBar;

my $start_time = time;

#db connections
my $newdb = new TAN::Model::MySQL;
my $olddb = new TAN::Model::OldDB;

#lookup hashes old => new
my $user_lookup = {};
my $link_lookup = {};
my $blog_lookup = {};
my $picture_lookup = {};
my $tag_lookup = {};
my $user_comment_no = {};

my $old_avatar_path = '/mnt/stuff/avatar';
my $new_avatar_path = '/mnt/stuff/TAN/user/avatar';

my ( $count, $loop, $progress );

#USERS
my $old_users = $olddb->resultset('UserDetails')->search({},{
    'order_by' => 'user_id',
});

$count = $old_users->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Users      ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_user = $old_users->next){
    my $new_user = $newdb->resultset('User')->create({
        'username' => $old_user->username,
        'join_date' => $old_user->join_date,
        'email' => $old_user->email,
        'password' => $old_user->password,
        'confirmed' => $old_user->confirmed,
        'deleted' => 'N',
    });

    $user_lookup->{$old_user->user_id} = $new_user->id;

    #convert avatar
    my $old_avatar = $old_avatar_path . '/' . $old_user->user_id . '.jpg';
    my $new_avatar = $new_avatar_path . '/' . $new_user->user_id;
    if ( -f $old_avatar ){
        copy($old_avatar, $new_avatar) or warn 'error';
    }

    my $old_lookup = $newdb->resultset('OldLookup')->create({
        'new_id' => $new_user->user_id,
        'old_id' => $old_user->user_id,
        'type' => 'user',
    });

    $progress->update( ++$loop );
}
print "\n";

#PICTURES
#   needs
#       user
my $old_pictures = $olddb->resultset('PictureDetails')->search({},{
    'order_by' => 'picture_id'
});

$count = $old_pictures->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Pictures   ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_picture = $old_pictures->next){
    my $new_object = $newdb->resultset('Object')->create({
        'type' => 'picture',
        'created' => $old_picture->date,
        'promoted' => $old_picture->promoted || 0,
        'user_id' => $user_lookup->{$old_picture->user_id} || 1, #assign things from none users to me!
        'nsfw' => $old_picture->nsfw,
    });

    my $old_lookup = $newdb->resultset('OldLookup')->create({
        'new_id' => $new_object->id,
        'old_id' => $old_picture->picture_id,
        'type' => 'picture',
    });
    
    $picture_lookup->{$old_picture->picture_id} = $new_object->id;

#work out pic mod
    my $pic_filename = basename($old_picture->filename);
    $pic_filename =~ /^(\d+)/;
    my $pic_time = $1;
    my $pic_mod = ($pic_time - ($pic_time % 604800));
    my $pic_path = "${pic_mod}/$pic_filename";
#move old_pic to new_pic/mod

#this shouldn't be hardcoded....
    mkpath("/mnt/stuff/TAN/user/pics/${pic_mod}");
    copy("/mnt/stuff/images/pics/${pic_filename}", "/mnt/stuff/TAN/user/pics/${pic_path}");

#work out pic 512sum
    open(INFILE, "/mnt/stuff/TAN/user/pics/${pic_path}");
    my $sha = new Digest::SHA(512);
    $sha->addfile(*INFILE);
    my $pic_sha512 = $sha->hexdigest();
    close(INFILE);

    my $new_blog = $newdb->resultset('Picture')->create({
        'picture_id' => $new_object->id,
        'title' => strip_slashes(decode_entities($old_picture->title)),
        'description' => strip_slashes(decode_entities($old_picture->description)),
        'filename' => $pic_path,
        'x' => $old_picture->x,
        'y' => $old_picture->y,
        'size' => $old_picture->size,
        'sha512sum' => $pic_sha512,
    });

    $progress->update( ++$loop );
}
print "\n";

#BLOGS
#   needs
#       user
#       picture
my $old_blogs = $olddb->resultset('BlogDetails')->search({},{
    'order_by' => 'blog_id'
});

$count = $old_blogs->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Blogs      ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_blog = $old_blogs->next){
    my $new_object = $newdb->resultset('Object')->create({
        'type' => 'blog',
        'created' => $old_blog->date,
        'promoted' => $old_blog->promoted || 0,
        'user_id' => $user_lookup->{$old_blog->user_id} || 1, #assign things from none users to me!
        'nsfw' => 'N',
    });

    my $old_lookup = $newdb->resultset('OldLookup')->create({
        'new_id' => $new_object->id,
        'old_id' => $old_blog->blog_id,
        'type' => 'blog',
    });
    
    $blog_lookup->{$old_blog->blog_id} = $new_object->id;

    my $new_pic_id = $picture_lookup->{$old_blog->category};
    my $new_blog = $newdb->resultset('Blog')->create({
        'blog_id' => $new_object->id,
        'title' => strip_slashes(decode_entities($old_blog->title)),
        'description' => strip_slashes(decode_entities($old_blog->description)),
        'picture_id' => $new_pic_id || 1,
        'details' => strip_slashes($old_blog->details),
    });

    $progress->update( ++$loop );
}
print "\n";

#LINKS
#   needs
#       user
#       picture
my $old_links = $olddb->resultset('LinkDetails')->search({},{
    'order_by' => 'link_id'
});

$count = $old_links->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Links      ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_link = $old_links->next){
    if ($user_lookup->{$old_link->user_id}){
        my $new_object = $newdb->resultset('Object')->create({
            'type' => 'link',
            'created' => $old_link->date,
            'promoted' => $old_link->promoted || 0,
            'user_id' => $user_lookup->{$old_link->user_id} || 1, #assign things from none users to me!
            'nsfw' => 'N',
        });
        
        my $old_lookup = $newdb->resultset('OldLookup')->create({
            'new_id' => $new_object->id,
            'old_id' => $old_link->link_id,
            'type' => 'link',
        });
        
        $link_lookup->{$old_link->link_id} = $new_object->id;
    
        my $new_pic_id = $picture_lookup->{$old_link->category};
        my $new_link = $newdb->resultset('Link')->create({
            'link_id' => $new_object->id,
            'title' => strip_slashes(decode_entities($old_link->title)),
            'description' => strip_slashes(decode_entities($old_link->description)),
            'picture_id' => $new_pic_id || 1,
            'url' => strip_slashes(decode_entities($old_link->url)),
        });
    }

    $progress->update( ++$loop );
}

print "\n";

#TAGS
my $old_tags = $olddb->resultset('Tags')->search({},{
    'order_by' => 'tag_id'
});

$count = $old_tags->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Tags       ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_tag = $old_tags->next){
    my $new_tag = $newdb->resultset('Tags')->create({
        'tag' => $old_tag->tag,
    });

    $tag_lookup->{$old_tag->tag_id} = $new_tag->tag_id;

    $progress->update( ++$loop );
}
print "\n";

#TAG_OBJECTS
#   needs
#       objects
#       user
#       tags
my $old_tagds = $olddb->resultset('TagDetails');

$count = $old_tagds->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Tag Details',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_tag = $old_tagds->next){
    my $newid;
    if ($old_tag->link_id > 0){
        $newid = $link_lookup->{$old_tag->link_id};
    } elsif ($old_tag->blog_id > 0){
        $newid = $blog_lookup->{$old_tag->blog_id};
    } elsif ($old_tag->picture_id > 0){
        $newid = $picture_lookup->{$old_tag->picture_id};
    }
    
    if ($newid){
        my $new_tag = $newdb->resultset('TagObjects')->create({
            'tag_id' => $tag_lookup->{$old_tag->tag_id},
            'user_id' => $user_lookup->{$old_tag->user_id} || 1, #assign things from none users to me!
            'object_id' => $newid,
            'created' => $old_tag->date,
        });
    }

    $progress->update( ++$loop );
}
print "\n";

#COMMENTS
#   needs
#       objects
#       user
my $old_comments = $olddb->resultset('Comments')->search({},{
    'order_by' => 'comment_id'
});

$count = $old_comments->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Comments   ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_comment = $old_comments->next){
    if ($user_lookup->{$old_comment->user_id}){
        my $newid;
        if ($old_comment->link_id){
            $newid = $link_lookup->{$old_comment->link_id};
        } elsif ($old_comment->blog_id){
            $newid = $blog_lookup->{$old_comment->blog_id};
        } elsif ($old_comment->picture_id){
            $newid = $picture_lookup->{$old_comment->picture_id};
        }

        if ( defined($user_comment_no->{ $user_lookup->{$old_comment->user_id} }) ){
            ++$user_comment_no->{ $user_lookup->{$old_comment->user_id} };
        } else {
            $user_comment_no->{ $user_lookup->{$old_comment->user_id} } = 1;
        }


        if ($newid){
            my $new_comment = $newdb->resultset('Comments')->create({
                'user_id' => $user_lookup->{$old_comment->user_id},
                'comment' => strip_slashes($old_comment->details),
                'created' => $old_comment->date,
                'object_id' => $newid,
                'deleted' => $old_comment->deleted,
                'number' => $user_comment_no->{ $user_lookup->{$old_comment->user_id} },
            });
        }
    }

    $progress->update( ++$loop );
}
print "\n";

#PLUS
#   needs
#       objects
#       user
my $old_pluss = $olddb->resultset('Plus')->search({},{
    'order_by' => 'plus_id',
});

$count = $old_pluss->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Plus       ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_plus = $old_pluss->next){
    if ($user_lookup->{$old_plus->user_id}){
        my $newid;
        if ($old_plus->link_id){
            $newid = $link_lookup->{$old_plus->link_id};
        } elsif ($old_plus->blog_id){
            $newid = $blog_lookup->{$old_plus->blog_id};
        } elsif ($old_plus->picture_id){
            $newid = $picture_lookup->{$old_plus->picture_id};
        }
        if ($newid){
            my $new_plus = $newdb->resultset('PlusMinus')->create({
                'user_id' => $user_lookup->{$old_plus->user_id},
                'object_id' => $newid,
                'type' => 'plus',
            });
        }
    }

    $progress->update( ++$loop );
}
print "\n";

#MINUS
#   needs
#       objects
#       user
my $old_minuss = $olddb->resultset('Minus')->search({},{
    'order_by' => 'minus_id'
});

$count = $old_minuss->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Minus      ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_plus = $old_minuss->next){
    if ($user_lookup->{$old_plus->user_id}){
        my $newid;
        if ($old_plus->link_id){
            $newid = $link_lookup->{$old_plus->link_id};
        } elsif ($old_plus->blog_id){
            $newid = $blog_lookup->{$old_plus->blog_id};
        } elsif ($old_plus->picture_id){
            $newid = $picture_lookup->{$old_plus->picture_id};
        }
        if ($newid){
            my $new_plus = $newdb->resultset('PlusMinus')->create({
                'user_id' => $user_lookup->{$old_plus->user_id},
                'object_id' => $newid,
                'type' => 'minus',
            });
        }
    }

    $progress->update( ++$loop );
}
print "\n";

#VIEWS
#   needs
#       objects
#       user
my $old_pis = $olddb->resultset('Pi');

$count = $old_pis->count;
$loop = 0;
$progress = Term::ProgressBar->new({
    'name' => 'Views      ',
    'count' => $count,
    'ETA' => 'linear',
    'bar_width' => 50,
});

while (my $old_pi = $old_pis->next){
    my $newid = '';
    if ($old_pi->type eq 'link'){
        $newid = defined($old_pi->id) && defined($link_lookup->{$old_pi->id}) ? $link_lookup->{$old_pi->id} : '';
    } elsif ($old_pi->type eq 'blog'){
        $newid = defined($old_pi->id) && defined($blog_lookup->{$old_pi->id}) ? $blog_lookup->{$old_pi->id} : '';
    } elsif ($old_pi->type eq 'picture'){
        $newid = defined($old_pi->id) && defined($picture_lookup->{$old_pi->id}) ? $picture_lookup->{$old_pi->id} : '';
    }
    my $uid = (defined($old_pi->user_id) && defined($user_lookup->{$old_pi->user_id})) ? $user_lookup->{$old_pi->user_id} : '';

    my $params = {
        'ip' => $old_pi->ip,
        'object_id' => $newid,
        'session_id' => $old_pi->session_id,
        'user_id' => $uid,
        'created' => $old_pi->date,
    };

    if ($newid ne ''){
        my $new_view = $newdb->resultset('Views')->create($params);
    }

    $progress->update( ++$loop );

}
print "\n";

sub strip_slashes{
    my $string = shift;
    if ($string){
        $string =~ s/\\(\'|\"|\\)/$1/g;
    }
    return $string;
}

my $time = (time - $start_time);

print "\ntook ${time} seconds";

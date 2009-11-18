use strict;
use warnings;

use lib '../../lib';
use TAN::Model::MySQL;
use TAN::Model::OldDB;

use HTML::Entities;
use File::Basename;

#db connections
my $newdb = new TAN::Model::MySQL;
my $olddb = new TAN::Model::OldDB;

#lookup hashes old => new
my $user_lookup = {};
my $link_lookup = {};
my $blog_lookup = {};
my $picture_lookup = {};
my $tag_lookup = {};

#USERS
my $old_users = $olddb->resultset('UserDetails');
foreach my $old_user ($old_users->all){
    my $new_user = $newdb->resultset('User')->create({
        'username' => $old_user->username,
        'join_date' => $old_user->join_date,
        'email' => $old_user->email,
        'password' => $old_user->password,
        'confirmed' => $old_user->confirmed,
        'deleted' => 'N',
    });

    $user_lookup->{$old_user->user_id} = $new_user->id;
}
print "converted " . $old_users->count . " users\n";

#PICTURES
#   needs
#       user
my $old_pictures = $olddb->resultset('PictureDetails');
foreach my $old_picture ($old_pictures->all){
    if ($user_lookup->{$old_picture->user_id}){
        my $new_object = $newdb->resultset('Object')->create({
            'type' => 'picture',
            'created' => $old_picture->date,
            'promoted' => $old_picture->promoted || 0,
            'user_id' => $user_lookup->{$old_picture->user_id},
            'nsfw' => $old_picture->nsfw,
        });

        my $old_lookup = $newdb->resultset('OldLookup')->create({
            'new_id' => $new_object->id,
            'old_id' => $old_picture->picture_id,
        });
        
        $picture_lookup->{$old_picture->picture_id} = $new_object->id;

        my $new_blog = $newdb->resultset('Picture')->create({
            'picture_id' => $new_object->id,
            'title' => decode_entities($old_picture->title),
            'description' => decode_entities($old_picture->description),
            'filename' => basename($old_picture->filename),
            'x' => $old_picture->x,
            'y' => $old_picture->y,
            'size' => $old_picture->size,
        });
    }
}
print "converted " . $old_pictures->count . " pictures\n";

#BLOGS
#   needs
#       user
#       picture
my $old_blogs = $olddb->resultset('BlogDetails');
foreach my $old_blog ($old_blogs->all){
    if ($user_lookup->{$old_blog->user_id}){
        my $new_object = $newdb->resultset('Object')->create({
            'type' => 'blog',
            'created' => $old_blog->date,
            'promoted' => $old_blog->promoted || 0,
            'user_id' => $user_lookup->{$old_blog->user_id},
            'nsfw' => 'N',
        });

        my $old_lookup = $newdb->resultset('OldLookup')->create({
            'new_id' => $new_object->id,
            'old_id' => $old_blog->blog_id,
        });
        
        $blog_lookup->{$old_blog->blog_id} = $new_object->id;
    
        my $new_blog = $newdb->resultset('Blog')->create({
            'blog_id' => $new_object->id,
            'title' => decode_entities($old_blog->title),
            'description' => decode_entities($old_blog->description),
            'picture_id' => $picture_lookup->{$old_blog->category} || 1,
            'details' => decode_entities($old_blog->details),
        });
    }
}
print "converted " . $old_blogs->count . " blogs\n";

#LINKS
#   needs
#       user
#       picture
my $old_links = $olddb->resultset('LinkDetails');
foreach my $old_link ($old_links->all){
    if ($user_lookup->{$old_link->user_id}){
        my $new_object = $newdb->resultset('Object')->create({
            'type' => 'link',
            'created' => $old_link->date,
            'promoted' => $old_link->promoted || 0,
            'user_id' => $user_lookup->{$old_link->user_id},
            'nsfw' => 'N',
        });
        
        my $old_lookup = $newdb->resultset('OldLookup')->create({
            'new_id' => $new_object->id,
            'old_id' => $old_link->link_id,
        });
        
        $link_lookup->{$old_link->link_id} = $new_object->id;
    
        my $new_link = $newdb->resultset('Link')->create({
            'link_id' => $new_object->id,
            'title' => decode_entities($old_link->title),
            'description' => decode_entities($old_link->description),
            'picture_id' => $picture_lookup->{$old_link->category} || 1,
            'url' => decode_entities($old_link->url),
        });
    }
}
print "converted " . $old_links->count . " links\n";

#TAGS
my $old_tags = $olddb->resultset('Tags');
foreach my $old_tag ($old_tags->all){
    my $new_tag = $newdb->resultset('Tags')->create({
        'tag' => $old_tag->tag,
    });

    $tag_lookup->{$old_tag->tag_id} = $new_tag->tag_id;
}
print "converted " . $old_tags->count . " tags\n";

#TAG_OBJECTS
#   needs
#       objects
#       user
#       tags
my $old_tagds = $olddb->resultset('TagDetails');
foreach my $old_tag ($old_tagds->all){
    if ($user_lookup->{$old_tag->user_id}){
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
                'user_id' => $user_lookup->{$old_tag->user_id},
                'object_id' => $newid,
                'created' => $old_tag->date,
            });
        }
    }
}
print "converted " . $old_tagds->count . " tag details\n";

#COMMENTS
#   needs
#       objects
#       user
my $old_comments = $olddb->resultset('Comments');
foreach my $old_comment ($old_comments->all){
    if ($user_lookup->{$old_comment->user_id}){
        my $newid;
        if ($old_comment->link_id){
            $newid = $link_lookup->{$old_comment->link_id};
        } elsif ($old_comment->blog_id){
            $newid = $blog_lookup->{$old_comment->blog_id};
        } elsif ($old_comment->picture_id){
            $newid = $picture_lookup->{$old_comment->picture_id};
        }
        if ($newid){
            my $new_comment = $newdb->resultset('Comments')->create({
                'user_id' => $user_lookup->{$old_comment->user_id},
                'comment' => $old_comment->details,
                'created' => $old_comment->date,
                'object_id' => $newid,
                'deleted' => $old_comment->deleted,
            });
        }
    }
}
print "converted " . $old_comments->count . " comments\n";

#PLUS
#   needs
#       objects
#       user
my $old_pluss = $olddb->resultset('Plus');
foreach my $old_plus ($old_pluss->all){
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
}
print "converted " . $old_pluss->count . " plus\n";

#MINUS
#   needs
#       objects
#       user
my $old_minuss = $olddb->resultset('Minus');
foreach my $old_plus ($old_minuss->all){
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
}
print "converted " . $old_minuss->count . " minus\n";

#VIEWS
#   needs
#       objects
#       user
my $old_pis = $olddb->resultset('Pi');
foreach my $old_pi ($old_pis->all){
    if ($user_lookup->{$old_pi->user_id}){
        my $newid;
        if ($old_pi->type eq 'link'){
            $newid = $link_lookup->{$old_pi->id};
        } elsif ($old_pi->type eq 'blog'){
            $newid = $blog_lookup->{$old_pi->id};
        } elsif ($old_pi->type eq 'picture'){
            $newid = $picture_lookup->{$old_pi->id};
        }
        
        my $new_view = $newdb->resultset('Views')->create({
            'ip' => $old_pi->ip,
            'object_id' => $newid,
            'session_id' => $old_pi->session_id,
            'user_id' => $old_pi->user_id,
            'created' => $old_pi->date,
        });
    }
}
print "converted " . $old_pis->count . " views\n";

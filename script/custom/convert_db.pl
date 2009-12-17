use strict;
use warnings;

use lib '../../lib';
use TAN::Model::MySQL;
use TAN::Model::OldDB;

use HTML::Entities;
use File::Basename;

use Data::Dumper;

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
}
print "converted " . $old_users->count . " users\n";

#PICTURES
#   needs
#       user
my $old_pictures = $olddb->resultset('PictureDetails');
while (my $old_picture = $old_pictures->next){
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
            'type' => 'picture',
        });
        
        $picture_lookup->{$old_picture->picture_id} = $new_object->id;

        my $new_blog = $newdb->resultset('Picture')->create({
            'picture_id' => $new_object->id,
            'title' => strip_slashes(decode_entities($old_picture->title)),
            'description' => strip_slashes(decode_entities($old_picture->description)),
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
while (my $old_blog = $old_blogs->next){
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
            'type' => 'blog',
        });
        
        $blog_lookup->{$old_blog->blog_id} = $new_object->id;
    
        my $new_blog = $newdb->resultset('Blog')->create({
            'blog_id' => $new_object->id,
            'title' => strip_slashes(decode_entities($old_blog->title)),
            'description' => strip_slashes(decode_entities($old_blog->description)),
            'picture_id' => $picture_lookup->{$old_blog->category} || 1,
            'details' => strip_slashes($old_blog->details),
        });
    }
}
print "converted " . $old_blogs->count . " blogs\n";

#LINKS
#   needs
#       user
#       picture
my $old_links = $olddb->resultset('LinkDetails');
while (my $old_link = $old_links->next){
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
            'type' => 'link',
        });
        
        $link_lookup->{$old_link->link_id} = $new_object->id;
    
        my $new_link = $newdb->resultset('Link')->create({
            'link_id' => $new_object->id,
            'title' => strip_slashes(decode_entities($old_link->title)),
            'description' => strip_slashes(decode_entities($old_link->description)),
            'picture_id' => $picture_lookup->{$old_link->category} || 1,
            'url' => strip_slashes(decode_entities($old_link->url)),
        });
    }
}
print "converted " . $old_links->count . " links\n";

#TAGS
my $old_tags = $olddb->resultset('Tags');
while (my $old_tag = $old_tags->next){
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
while (my $old_tag = $old_tagds->next){
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
        if ($newid){
            my $new_comment = $newdb->resultset('Comments')->create({
                'user_id' => $user_lookup->{$old_comment->user_id},
                'comment' => strip_slashes($old_comment->details),
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
}
print "converted " . $old_pluss->count . " plus\n";

#MINUS
#   needs
#       objects
#       user
my $old_minuss = $olddb->resultset('Minus');
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
}
print "converted " . $old_minuss->count . " minus\n";

#VIEWS
#   needs
#       objects
#       user
my $old_pis = $olddb->resultset('Pi');
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
}
print "converted " . $old_pis->count . " views\n";

sub strip_slashes{
    my $string = shift;
    if ($string){
        $string =~ s/\\(\'|\"|\\)/$1/g;
    }
    return $string;
}

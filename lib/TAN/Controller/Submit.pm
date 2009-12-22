package TAN::Controller::Submit;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Data::Validate::URI;
use Time::HiRes qw/time/;
=head2 index

=cut
my $location_reg = qr/^link|blog|picture$/;
my $int_reg = qr/\D+/;

=head2 location
checks the location is valid
=cut
sub location: PathPart('submit') Chained('/') CaptureArgs(1){
    my ( $self, $c, $location ) = @_;

    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/');
        $c->detach();
    }

    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }
    $c->stash->{'location'} = $location;
}


=head2 index
the submit page
=cut
sub index : PathPart('') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'submit.tt';
}


=head2 validate
validates the upload
=cut

#no point redefining these on each request...
my $title_min = 3;
my $desc_min = 5;
my $title_max = 100;
my $desc_max = 1000;
my $blog_min = 20;

my @error_codes = (
    'Title cannont be blank',
    'Description cannot be blank',
    "Title cannot be over ${title_max} characters",
    "Description cannot be over ${desc_max} characters",
    "Title must be over ${title_min} characters",
    "Description must be over ${desc_min} characters",
    'Url is invalid',
    'This link has already been submitted',
    "Blog must be over ${blog_min} characters",
    "Please select an image",
);
sub validate: PathPart('') Chained('location') CaptureArgs(0){
    my ( $self, $c ) = @_;

    my $title = $c->req->param('title');
    my $description = $c->req->param('description');

    if ( $title eq '' ) {
        #blank title
        $c->stash->{'error'} = $error_codes[0];

    } elsif ( length($title) > $title_max ) {
        #long title
        $c->stash->{'error'} = $error_codes[2];

    } elsif ( defined($c->req->param('description')) && length($c->req->param('description')) > $desc_max ) {
        #long description
        $c->stash->{'error'} = $error_codes[3];

    } elsif ( !defined($title) || length($title) < $title_min ) {
        #short title
        $c->stash->{'error'} = $error_codes[4];

    } else {
        my $cat;
        if ($c->stash->{'location'} eq 'link'){
            $cat = $c->req->param('cat');
            $cat =~s/$int_reg//g;
            if (!defined($cat)){
                #no image selected
                $c->stash->{'error'} = $error_codes[9];
            }

            if (length($description) < $desc_min){
                #desc too short
                $c->stash->{'error'} = $error_codes[5];
            }

            my $valid_url = Data::Validate::URI->new();
            my $url = $c->req->param('url');

            if ( !defined($valid_url->is_web_uri($url)) ){
                #invalid url
                $c->stash->{'error'} = $error_codes[6];                
            }

            my $link = $c->model('MySQL::Link')->search({
                'url' => $url,
            });

            if ($link->count){
               #already submitted
                $c->stash->{'error'} = $error_codes[7];
            }

        } elsif ($c->stash->{'location'} eq 'blog') {
            $cat = $c->req->param('cat');
            $cat =~s/$int_reg//g;
            if (!defined($cat)){
                #no image selected
                $c->stash->{'error'} = $error_codes[9];
            }

            if (length($description) < $desc_min){
                #desc too short
                $c->stash->{'error'} = $error_codes[5];
            }

            if (length($c->req->param('blogmain')) < $blog_min) {
                #blog too short
                $c->stash->{'error'} = $error_codes[8];
            }
        } elsif ($c->stash->{'location'} eq 'picture') {
            my $url = $c->req->param('pic_url');
            if (defined($url)){
                my $valid_url = Data::Validate::URI->new();
                if ( !defined($valid_url->is_web_uri($url)) ){
                    #invalid url
                    $c->stash->{'error'} = $error_codes[6];                
                }
            }
        }
    }
}

=head2 post
post logic
=cut
sub post: PathPart('post') Chained('validate') Args(0){
    my ( $self, $c ) = @_;

    if ($c->stash->{'error'}){
        $c->flash->{'message'} = $c->stash->{'error'};
        $c->res->redirect('/submit/' . $c->stash->{'location'} . '/');
        $c->detach();
    }

    if ($c->stash->{'location'} eq 'link'){
        my $object = $c->model('MySQL::Object')->create({
            'type' => $c->stash->{'location'},
            'created' => \'NOW()',
            'promoted' => 0,
            'user_id' => $c->user->user_id,
            'nsfw' => 'N',
            'rev' => 0,
            'link' => {
                'title' => $c->req->param('title'),
                'description' => $c->req->param('description'),
                'picture_id' => $c->req->param('cat'),
                'url' => $c->req->param('url'),
            },
            'plus_minus' => [{
                'type' => 'plus',
                'user_id' => $c->user->user_id,
            }],
        });

        if (!$object->id){
            $c->flash->{'message'} = 'Error submitting link';
        }
        $c->res->redirect('/index/all/1/1/');
        $c->detach();
    } elsif ($c->stash->{'location'} eq 'blog'){
        my $object = $c->model('MySQL::Object')->create({
            'type' => $c->stash->{'location'},
            'created' => \'NOW()',
            'promoted' => 0,
            'user_id' => $c->user->user_id,
            'nsfw' => 'N',
            'rev' => 0,
            'blog' => {
                'title' => $c->req->param('title'),
                'description' => $c->req->param('description'),
                'picture_id' => $c->req->param('cat'),
                'details' => $c->req->param('blogmain'),
            },
            'plus_minus' => [{
                'type' => 'plus',
                'user_id' => $c->user->user_id,
            }],
        });

        if (!$object->id){
            $c->flash->{'message'} = 'Error submitting blog';
        }
        $c->res->redirect('/index/all/1/1/');
        $c->detach();
    } elsif ($c->stash->{'location'} eq 'picture') {
        my $title = $c->req->param('title');

        my $url_title = $c->url_title($title);
        my @path = split('/', 'root/' . $c->config->{'pic_path'} . '/' . time . '_' . $url_title);

        if ( my $filepath = $c->model('FetchImage')->fetch($c->req->param('pic_url'), $c->path_to(@path)) ){
warn $filepath;
            my @path = split('/', $filepath);
            my $filename = $path[-1];
warn $filename;
            my $object = $c->model('MySQL::Object')->create({
                'type' => $c->stash->{'location'},
                'created' => \'NOW()',
                'promoted' => 0,
                'user_id' => $c->user->user_id,
                'nsfw' => defined($c->req->param('nsfw')) ? 'Y' : 'N',
                'rev' => 0,
                'picture' => {
                    'title' => $title,
                    'description' => $c->req->param('pdescription') || '',
                    'filename' => $filename,
                    'x' => 1,
                    'y' => 1,
                    'size' => 3,
                },
                'plus_minus' => [{
                    'type' => 'plus',
                    'user_id' => $c->user->user_id,
                }],
            });
        } else {
            $c->flash->{'message'} = 'Error submitting picture';
        }
    }

    # submit
    # redirect
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

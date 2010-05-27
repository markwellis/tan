package TAN::Controller::Submit;
use strict;
use warnings;

use parent 'Catalyst::Controller';

use Data::Validate::URI;

my $int_reg = qr/\D+/;
my $tag_reg = qr/[^a-zA-Z0-9]/;

=head1 NAME

TAN::Controller::Submit

=head1 DESCRIPTION

Submit controller

=head1 EXAMPLE

I</submit/$location/>

=over

submission form

=over

$location => link|blog|picture

=back

=back

I</submit/$location/post>

=over

post here

=back

=head1 METHODS

=cut

=head2 location: PathPart('submit') Chained('/') CaptureArgs(1)

B<@args = ($location)>

=over

checks user is logged in

checks the location is valid

=back

=cut
my $location_reg = qr/^link|blog|picture$/;
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

=head2 index: PathPart('') Chained('location') Args(0) 

B<@args = undef>

=over

loads the submit template

=back

=cut
sub index: PathPart('') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'submit.tt';
}


=head2 validate: PathPart('') Chained('location') CaptureArgs(0)

B<@args = undef>

B<@params = (title, description)>

=over

validates generic submission things (title etc)

forwards to validate_$location

=back

=cut

#no point redefining these on each request...
my $title_min = 3;
my $desc_min = 5;
my $title_max = 100;
my $blog_min = 20;

my $error_codes = {
    'blank_title' => 'Title cannont be blank',
    'blank_desc' => 'Description cannot be blank',
    'short_title' => "Title must be over ${title_min} characters",
    'short_desc' => "Description must be over ${desc_min} characters",
    'short_blog' => "Blog must be over ${blog_min} characters",
    'long_title' => "Title cannot be over ${title_max} characters",
    'invalid_url' => 'Url is invalid',
    'already_submitted' => 'This link has already been submitted',
    'no_image' => "Please select an image",
    'too_large' => "Filesize exceeded",
};
sub validate: PathPart('') Chained('location') CaptureArgs(0){
    my ( $self, $c ) = @_;

    my $title = $c->req->param('title');
    my $description = $c->req->param('description');

    if ( $title eq '' ) {
    #blank title
        $c->stash->{'error'} = $error_codes->{'blank_title'};

    } elsif ( !defined($title) || length($title) < $title_min ) {
    #short title
        $c->stash->{'error'} = $error_codes->{'short_title'};

    } elsif ( length($title) > $title_max ) {
    #long title
        $c->stash->{'error'} = $error_codes->{'long_title'};

    } else {
        if ($c->stash->{'location'} eq 'link'){
        #validate link specific details
            $c->forward('validate_link');

        } elsif ($c->stash->{'location'} eq 'blog') {
        #validate blog specific details
            $c->forward('validate_blog');

        } elsif ($c->stash->{'location'} eq 'picture') {
        #validate picture specific details
            $c->forward('validate_picture');
        }
    }
}

=head2 validate_link: Private

B<@args = undef>

B<@params = (description, cat, url)>

=over

validates link specific details

=back

=cut
sub validate_link: Private{
    my ( $self, $c ) = @_;

    my $description = $c->req->param('description');
    my $cat = $c->req->param('cat');

    $cat =~s/$int_reg//g;
    if (!defined($cat)){
    #no image selected
        $c->stash->{'error'} = $error_codes->{'no_image'};
    }

    if (length($description) < $desc_min){
    #desc too short
        $c->stash->{'error'} = $error_codes->{'short_desc'};
    }

    my $valid_url = Data::Validate::URI->new();
    my $url = $c->req->param('url');

    if ( !defined($valid_url->is_web_uri($url)) ){
    #invalid url
        $c->stash->{'error'} = $error_codes->{'invalid_url'};                
    }

    my $link = $c->model('MySQL::Link')->search({
        'url' => $url,
    });

    if ($link->count){
    #already submitted
        $c->stash->{'error'} = $error_codes->{'already_submitted'};
        $c->stash->{'link_id'} = $link->first->link_id;
    }
}

=head2 validate_blog: Private

B<@args = undef>

B<@params = (description, cat, blogmain)>

=over

validates blog specific details

=back

=cut
sub validate_blog: Private{
    my ( $self, $c ) = @_;
    
    my $description = $c->req->param('description');
    my $cat = $c->req->param('cat');

    $cat =~ s/$int_reg//g;
    if (!defined($cat)){
    #no image selected
        $c->stash->{'error'} = $error_codes->{'no_image'};
    }

    if (length($description) < $desc_min){
    #desc too short
        $c->stash->{'error'} = $error_codes->{'short_desc'};
    }

    if (length($c->req->param('blogmain')) < $blog_min) {
    #blog too short
        $c->stash->{'error'} = $error_codes->{'short_blog'};
    }
}

=head2 validate_picture: Private

B<@args = undef/>

B<@params = (pic_url, pic)>

=over

validates picture specific details

=back

=cut
sub validate_picture: Private{
    my ( $self, $c ) = @_;

    my $title = $c->req->param('title');
    my $url_title = $c->url_title($title);
    my @path = split('/', 'root/' . $c->config->{'pic_path'} . '/' . time . '_' . $url_title);

    my ( $fileinfo, $fetcher ) = (0, undef);

    my $url = $c->req->param('pic_url');
    if ( $url ){
    #fetch
        my $valid_url = Data::Validate::URI->new();
        if ( !defined($valid_url->is_web_uri($url)) ){
        #invalid url
            $c->stash->{'error'} = $error_codes->{'invalid_url'};
        } else {
        #valid url, fetch and validate
            $fetcher = $c->model('FetchImage');
            $fileinfo = $fetcher->fetch($c->req->param('pic_url'), $c->path_to(@path));
            if ( !$fileinfo ){
                $c->stash->{'error'} = $fetcher->{'error'};
            }
        }
    } elsif (my $upload = $c->request->upload('pic')) {
    #upload
        if ( $upload->size > $c->config->{'Model::FetchImage'}->{'max_filesize'} ){
            $c->stash->{'error'} = $error_codes->{'too_large'};
        } else {
            $fileinfo = $c->model('ValidateImage')->is_image($upload->tempname);

            if( $fileinfo ){
            #is an image
                $fileinfo->{'filename'} = $c->path_to(@path) . '.' . $fileinfo->{'file_ext'};
                $upload->copy_to($fileinfo->{'filename'});
            } else {
                $c->stash->{'error'} = 'Invalid filetype';
            }
        }
    } else {
        $c->stash->{'error'} = 'No image';
    }

    if ( $fileinfo ) {
        $c->stash->{'fileinfo'} = $fileinfo;
    }
}

=head2 post: PathPart('post') Chained('validate') Args(0)

B<@args = undef>

=over

checks stash for $error

forwards to submit_$location

=back

=cut
sub post: PathPart('post') Chained('validate') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->stash->{'error'} ){
        $c->flash->{'message'} = $c->stash->{'error'};
        if ( defined($c->stash->{'link_id'}) ){
            #redirect to the object_url
        }
        $c->res->redirect('/submit/' . $c->stash->{'location'} . '/');
        $c->detach();
    }

    if ($c->stash->{'location'} eq 'link'){
    #submit link
        $c->forward('submit_link');

    } elsif ($c->stash->{'location'} eq 'blog'){
    #submit blog
        $c->forward('submit_blog');

    } elsif ($c->stash->{'location'} eq 'picture') {
    #submit picture
        $c->forward('submit_picture');

    }

    $c->flash->{'message'} = 'Submission complete';
    $c->res->redirect('/index/' . $c->stash->{'location'} . '/1/1/');
    $c->detach();
}

=head2 submit_link: Private

B<@args = undef>

B<@params = (title, description, cat, url)>

=over

submits a link

=back

=cut
sub submit_link: Private{
    my ( $self, $c ) = @_;

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

    $c->forward('add_tags', [$object]) if ( defined($object) );

    if ( !defined($object) || !$object->id ){
        $c->flash->{'message'} = 'Error submitting link';
    }
}

=head2 submit_blog: Private

B<@args = undef>

B<@params = (title, description, cat, blogmain)>

=over

submits a blog

=back

=cut
sub submit_blog: Private{
    my ( $self, $c ) = @_;

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

    $c->forward('add_tags', [$object]) if ( defined($object) );

    if ( !defined($object) || !$object->id ){
        $c->flash->{'message'} = 'Error submitting blog';
    }
}

=head2 submit_picture: Private

B<@args = undef>

B<@params = (nsfw, title, pdescription)>

=over

submits a picture

=back

=cut
sub submit_picture: Private{
    my ( $self, $c ) = @_;

    my $fileinfo = $c->stash->{'fileinfo'};

    my @path = split('/', $fileinfo->{'filename'});
    my $filename = $path[-1];

    my $object = $c->model('MySQL::Object')->create({
        'type' => $c->stash->{'location'},
        'created' => \'NOW()',
        'promoted' => 0,
        'user_id' => $c->user->user_id,
        'nsfw' => defined($c->req->param('nsfw')) ? 'Y' : 'N',
        'rev' => 0,
        'picture' => {
            'title' => $c->req->param('title'),
            'description' => $c->req->param('pdescription') || '',
            'filename' => $filename,
            'x' => $fileinfo->{'x'},
            'y' => $fileinfo->{'y'},
            'size' => $fileinfo->{'size'},
        },
        'plus_minus' => [{
            'type' => 'plus',
            'user_id' => $c->user->user_id,
        }],
    });

    $c->forward('add_tags', [$object]) if ( defined($object) );

    if ( !defined($object) || !$object->id ){
        $c->flash->{'message'} = 'Error submitting picture';
    }
}

=head2 add_tags: Private

B<@args = ($object)>

B<@params = (tags)>

=over

adds tags to $object

=back

=cut
sub add_tags: Private {
    my ( $self, $c, $object ) = @_;

    my @tags = split(/ /, lc($c->req->param('tags')));
    foreach my $tag ( @tags ){
        $tag =~ s/$tag_reg//g;

        if ( defined($tag) ){
            $object->add_to_tags({
                'tag' => $tag,
            });
        }
    }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

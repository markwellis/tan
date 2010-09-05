package TAN::Controller::Submit;
use strict;
use warnings;

use parent 'Catalyst::Controller';

use Data::Validate::URI;
use File::Path qw/mkpath/;
use Digest::SHA;

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
sub location: PathPart('submit') Chained('/') CaptureArgs(1){
    my ( $self, $c, $location ) = @_;

    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/');
        $c->detach();
    }

    my $location_reg = $c->model('CommonRegex')->location;
    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }
    $c->stash(
        'page_title' => 'Submit ' . ucfirst($location),
        'location' => $location,
        'no_ads' => 1,
    );
}

=head2 index: PathPart('') Chained('location') Args(0) 

B<@args = undef>

=over

loads the submit template

=back

=cut
sub index: PathPart('') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'Submit';
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
    'blank_title' => 'Title cannot be blank',
    'blank_desc' => 'Description cannot be blank',
    'short_title' => "Title must be over ${title_min} characters",
    'short_desc' => "Description must be over ${desc_min} characters",
    'short_blog' => "Blog must be over ${blog_min} characters",
    'long_title' => "Title cannot be over ${title_max} characters",
    'invalid_url' => 'Url is invalid',
    'already_submitted' => 'This has already been submitted',
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
    #validate location specific details
        $c->forward('validate_' . $c->stash->{'location'});
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

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $cat =~ s/$not_int_reg//g;
    if (!$cat){
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

    #edit mode
    if ( !defined($c->stash->{'object'}) ){
        my $link_rs = $c->model('MySQL::Link')->find({
            'url' => $url,
        });

        if ( $link_rs ){
        #already submitted
            $c->stash->{'error'} = $error_codes->{'already_submitted'};
            $c->stash->{'duplicate'} = $link_rs;
        }
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

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $cat =~ s/$not_int_reg//g;
    if (!$cat){
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

B<@args = undef>

B<@params = (pic_url, pic)>

=over

validates picture specific details

=back

=cut
sub validate_picture: Private{
    my ( $self, $c ) = @_;

    my $not_alpha_numeric_reg = TAN->model('CommonRegex')->not_alpha_numeric;

    my $title = $c->req->param('title');
    my $url_title = $title;
    $url_title =~ s/$not_alpha_numeric_reg/-/g;

    my $time = time;

#put images in a folder per week
    my $mod = ($time - ($time % 604800));

    my $path = $c->path_to('root') . $c->config->{'pic_path'} . "/${mod}";
    mkpath($path);
    $path .= "/${time}_${url_title}";

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
            $fileinfo = $fetcher->fetch($c->req->param('pic_url'), $path);
            if ( !$fileinfo ){
                $c->stash->{'error'} = $fetcher->{'error'};
            }
        }
    } elsif (my $upload = $c->request->upload('pic')) {
    #upload
        if ( $upload->size > $c->config->{'Model::FetchImage'}->{'args'}->{'max_filesize'} ){
            $c->stash->{'error'} = $error_codes->{'too_large'};
        } else {
            $fileinfo = $c->model('ValidateImage')->is_image($upload->tempname);

            if( $fileinfo ){
            #is an image
                $fileinfo->{'filename'} = $path . '.' . $fileinfo->{'file_ext'};
                $upload->copy_to($fileinfo->{'filename'});
            } else {
                $c->stash->{'error'} = 'Invalid filetype';
            }
        }
    } else {
        #not edit mode
        if ( !defined($c->stash->{'object'}) ){
            $c->stash->{'error'} = 'No image';
        }
    }

    if ( $fileinfo ) {
        open(INFILE, $fileinfo->{'filename'});
        my $sha = new Digest::SHA(512);
        $sha->addfile(*INFILE);
        $c->stash->{'pic_sha512'} = $sha->hexdigest();
        close(INFILE);

        my $pic_rs = $c->model('MySQL::Picture')->find({
            'sha512sum' => $c->stash->{'pic_sha512'},
        });
        if ( $pic_rs ){
        #already submitted
            $c->stash->{'error'} = $error_codes->{'already_submitted'};
            $c->stash->{'duplicate'} = $pic_rs;
        }

        $c->stash->{'fileinfo'} = $fileinfo;
    }
}

=head2 validate_poll: Private

B<@args = undef>

B<@params = (pic_url, pic)>

=over

validates picture specific details

=back

=cut
sub validate_poll: Private{
    my ( $self, $c ) = @_;
   
#must have at least 2 answers

    my $description = $c->req->param('description');
    my $cat = $c->req->param('cat');

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $cat =~ s/$not_int_reg//g;

    if (!$cat){
    #no image selected
        $c->stash->{'error'} = $error_codes->{'no_image'};
    }

    if (length($description) < $desc_min){
    #desc too short
        $c->stash->{'error'} = $error_codes->{'short_desc'};
    }

    my @answers = $c->req->param('answers');

    if ( ($answers[0] eq '') || ($answers[1]  eq '') ){
        $c->stash->{'error'} = 'Must have at least 2 answers';
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
        if ( defined($c->stash->{'duplicate'}) ){
            #redirect to the object_url
            $c->res->redirect($c->stash->{'duplicate'}->object->url);
            $c->detach();
        }

#flash the params here...
        my $object;
        if ( $c->stash->{'location'} eq 'link' ){
            $c->flash('object' => {
                'link' => {
                    'title' => $c->req->param('title') || undef,
                    'description' => $c->req->param('description') || undef,
                    'url' => $c->req->param('url') || undef,
                    'picture_id' => $c->req->param('cat') || undef,
                },
                'tags' => [
                    { 'tag' => $c->req->param('tags') || undef }
                ],
            });
        } elsif ( $c->stash->{'location'} eq 'blog' ){
            $c->flash('object' => {
                'blog' => {
                    'title' => $c->req->param('title') || undef,
                    'description' => $c->req->param('description') || undef,
                    'details' => $c->req->param('blogmain') || undef,
                    'picture_id' => $c->req->param('cat') || undef,
                },
                'tags' => [
                    { 'tag' => $c->req->param('tags') || undef }
                ],
            });
        } elsif ( $c->stash->{'location'} eq 'picture' ){
            $c->flash('object' => {
                'picture' => {
                    'title' => $c->req->param('title') || undef,
                    'description' => $c->req->param('description') || undef,
                    'pic_url' => $c->req->param('pic_url') || undef,
                },
                'tags' => [
                    { 'tag' => $c->req->param('tags') || undef }
                ],
                'nsfw' => defined($c->req->param('nsfw')) ? 'Y' : 'N',
            });
        } elsif ( $c->stash->{'location'} eq 'poll' ){
            $c->flash('object' => {
                'poll' => {
                    'title' => $c->req->param('title') || undef,
                    'description' => $c->req->param('description') || undef,
                    'picture_id' => $c->req->param('cat') || undef,
                    'answers' => [map({'answer' => $_}, $c->req->param('answers'))] || undef ,
                },
                'tags' => [
                    { 'tag' => $c->req->param('tags') || undef }
                ],
            });
        }

        $c->res->redirect('/submit/' . $c->stash->{'location'} . '/');
        $c->detach();
    }

    $c->forward('submit_' . $c->stash->{'location'});

    $c->trigger_event('object_created', $c->stash->{'object'});

    $c->flash->{'message'} = 'Submission complete';
    $c->res->redirect('/index/' . $c->stash->{'location'} . '/1/');
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
    $c->stash->{'object'} = $object;
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
    $c->stash->{'object'} = $object;
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
    my $filename = $path[-2] . '/' . $path[-1];

    my $object = $c->model('MySQL::Object')->create({
        'type' => $c->stash->{'location'},
        'created' => \'NOW()',
        'promoted' => 0,
        'user_id' => $c->user->user_id,
        'nsfw' => defined($c->req->param('nsfw')) ? 'Y' : 'N',
        'picture' => {
            'title' => $c->req->param('title'),
            'description' => $c->req->param('pdescription') || '',
            'filename' => $filename,
            'x' => $fileinfo->{'x'},
            'y' => $fileinfo->{'y'},
            'size' => $fileinfo->{'size'},
            'sha512sum' => $c->stash->{'pic_sha512'},
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
    $c->stash->{'object'} = $object;
}

=head2 submit_poll: Private

B<@args = undef>

B<@params = (title, description, cat, end_date, answers[])>

=over

submits a poll

=back

=cut
sub submit_poll: Private{
    my ( $self, $c ) = @_;

    my $days = $c->req->param('days');
    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $days =~ s/$not_int_reg//;
    $days ||= 3;
    $days = ( $days > 31 ) ? 31 : $days;

    my $answers;
    foreach my $answer ( $c->req->param('answers') ){
        if ( $answer ){
            push(@{$answers}, {
                'answer' => $answer,
            });
        }
    }

    my $object = $c->model('MySQL::Object')->create({
        'type' => $c->stash->{'location'},
        'created' => \'NOW()',
        'promoted' => 0,
        'user_id' => $c->user->user_id,
        'nsfw' => 'N',
        'poll' => {
            'title' => $c->req->param('title'),
            'description' => $c->req->param('description'),
            'picture_id' => $c->req->param('cat'),
            'end_date' => \"DATE_ADD(NOW(), INTERVAL ${days} DAY)",
            'answers' => $answers,
        },
        'plus_minus' => [{
            'type' => 'plus',
            'user_id' => $c->user->user_id,
        }],
    });

    $c->forward('add_tags', [$object]) if ( defined($object) );

    if ( !defined($object) || !$object->id ){
        $c->flash->{'message'} = 'Error submitting poll';
    }
    $c->stash->{'object'} = $object;
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

    my $tags_done = {};

    my $tag_reg = $c->model('CommonRegex')->not_alpha_numeric;
    foreach my $tag ( @tags ){
        $tag =~ s/$tag_reg//g;
        $tag =~ s/^\s+//;
        $tag =~ s/\s+$//;
        next if ( !$tag );

        if ( !defined($tags_done->{ $tag }) ){
            $tags_done->{ $tag } = 1;

            if ( defined($tag) ){
                $object->add_to_tags({
                    'tag' => $tag,
                });
            }
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

package TAN::Controller::Submit;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Data::Validate::URI;

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
my $title_min = 5;
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

    } elsif ( length($c->req->param('description')) > $desc_max ) {
        #long description
        $c->stash->{'error'} = $error_codes[3];

    } elsif ( length($title) < $title_min ) {
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
        }
        #no image validate here, yet...
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
warn $c->stash->{'location'};
warn Data::Dumper::Dumper($c->req->params);

    # validate
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

package TAN::View::Template::Classic::Lib::Index;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $is_picture = 0;
    if ( defined($c->stash->{'index'}) ){
        if ( 
            ($c->stash->{'location'} eq 'picture') 
            && $c->stash->{'fancy_picture_index'} 
        ){
            push(@{$c->stash->{'css_includes'}}, 'index@picture');
            $is_picture = 1;
        }

        my $loop = 0;
        foreach my $object ( @{$c->stash->{'index'}->{'objects'}} ){
            print '<li class="TAN-news' . (($loop % 2) ? ' TAN-news-alternate' : '') . '">';

            my $avatar_http = $c->config->{'avatar_path'} . "/" . $object->user_id;
            my $avatar_image = $c->path_to('root') . $avatar_http;
            my $avatar_exists = $c->view('Perl')->file_exists($avatar_image);

            $c->stash(
                'object' => $object,
                'avatar_http' => $avatar_http,
                'avatar_image' => $avatar_image,
                'avatar_exists' => $avatar_exists,
            );

            if ( $avatar_exists ){
                $c->stash->{'avatar_mtime'} = $c->view('Perl')->file_exists($avatar_image);
            } else {
                $c->stash->{'avatar_http'} = $c->config->static_path . '/images/_user.png';
            }

            if ( $is_picture ){
                $c->view->template('Lib::Index::Picture');
            } else {
                $c->view->template('Lib::Object');
            }

            print '</li>';
            ++$loop;
        }
    } else {
        print qq\
            <li class="TAN-news">
                <h1>Nothing found</h1>
            </li>\;
    }
}

1;

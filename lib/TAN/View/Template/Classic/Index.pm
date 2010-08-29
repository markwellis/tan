package TAN::View::Template::Classic::Index;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $out = '<ul class="TAN-inside">';

        if ( defined($c->stash->{'index'}) ){
            my $is_picture = 0;
            if ( 
                ($c->stash->{'location'} eq 'picture') 
                && $c->stash->{'fancy_picture_index'} 
            ){
                push(@{$c->stash->{'css_includes'}}, 'index@picture');
                $is_picture = 1;
            }

            my $loop = 0;
            foreach my $object ( @{$c->stash->{'index'}->{'objects'}} ){
                next if not $object;
                $out .= '<li class="TAN-news' . (($loop % 2) ? ' TAN-news-alternate' : '') . '">';

                my $avatar_http = $c->config->{'avatar_path'} . "/" . $object->user_id;
                my $avatar_image = $c->path_to('root') . $avatar_http;

                $c->stash(
                    'object' => $object,
                    'avatar_http' => $avatar_http,
                    'avatar_image' => $avatar_image,
                );

                if ( -e $avatar_image ){
                    $c->stash->{'avatar_mtime'} = $c->view('Perl')->file_mtime($avatar_image);
                } else {
                    $c->stash->{'avatar_http'} = $c->config->{'static_path'} . '/images/_user.png';
                }

                if ( $is_picture ){
                    $out .= $c->view->template('Index::Picture');
                } else {
                    $out .= $c->view->template('Lib::Object');
                }

                $out .= '</li>';
                ++$loop;
            }
        } else {
            $out .= qq\
                <li class="TAN-news">
                    <h1>Nothing found</h1>
                </li>\;
        }

    $out .= "</ul>
        @{[ $c->view->template('Index::Pagination', $c->stash->{'index'}->{'pager'}) ]}";

    return $out;
}

1;

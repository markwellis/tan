package TAN::View::Template::Classic::Index;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $out = '<ul class="TAN-inside">';

        if ( defined($c->stash->{'index'}) ){
            my $is_picture = 0;
            if ( 
                ($c->stash->{'type'} eq 'picture') 
                && $c->stash->{'fancy_picture_index'} 
            ){
                push(@{$c->stash->{'css_includes'}}, 'index@picture');
                $is_picture = 1;
            }

            my $loop = 0;
            foreach my $object ( @{$c->stash->{'index'}->{'objects'}} ){
                next if not $object;
                $out .= '<li class="TAN-news' . (($loop % 2) ? ' TAN-news-alternate' : '') . '">';

                $c->stash(
                    'object' => $object,
                );

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

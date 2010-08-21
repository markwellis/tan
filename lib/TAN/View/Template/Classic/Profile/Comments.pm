package TAN::View::Template::Classic::Profile::Comments;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'view');
    push(@{$c->stash->{'css_includes'}}, 'profile@comments');

    push(@{$c->stash->{'js_includes'}}, 'nsfw-comments');

    print '<ul class="TAN-inside TAN-comment_wrapper">';
    foreach my $comment ( $c->stash->{'comments'}->all ){
        print '<li class="TAN-news">';
            $c->view->template('View::Comment', $comment);
        print '</li>';
    }
    print '<li>';

    $c->view->template('Index::Pagination', $c->stash->{'comments'}->pager);

    print qq\</li>
        </ul>\;
}

1;

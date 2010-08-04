package TAN::View::Template::Classic::Index;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    print '<ul class="TAN-inside">';
    $c->stash->{'fancy_picture_index'} = 1;
    $c->view->template('Lib::Index');

    print '</ul>';

    $c->stash->{'pager'} = $c->stash->{'index'}->{'pager'};
    $c->view->template('Lib::Index::Pagination');
}

1;

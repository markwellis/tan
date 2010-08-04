package TAN::View::Template::Classic::Tag;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    print '<ul class="TAN-inside">';

    $c->view->template('Lib::Index');

    print '</ul>';

    $c->stash->{'pager'} = $c->stash->{'index'}->{'pager'};
    $c->view->template('Lib::Index::Pagination');
}

1;

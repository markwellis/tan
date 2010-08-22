package TAN::View::Template::RSS::Lib::Config;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    $c->stash(
        'page_meta_description' => 'Social News For Internet Pirates',
    );
    #rss theme config goes here...
}

1;

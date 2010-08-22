package TAN::View::Template::Classic::Lib::CssIncludes;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $out = '';
    foreach my $css_include ( @{$c->stash->{'css_includes'}} ){
#replace @ with / so we can get the file mod time
        my $css_file = $css_include;
        $css_file =~ s|@|/|g;

        my $m_time = $c->view->file_mtime("@{[ $c->path_to('root') ]}@{[ $c->stash->{'theme_settings'}->{'css_path'} ]}/${css_file}.css");

        $out .= qq\<link type="text/css" rel="stylesheet" media="screen" href="@{[ $c->config->{'csscache_path'} ]}/@{[ $c->stash->{'theme_settings'}->{'name'} ]}_${css_include}_${m_time}.css" />\;
    }

    return $out;
}

1;

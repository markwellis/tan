package TAN::View::Template::Classic::Lib::JsIncludes;

use base 'Catalyst::View::Perl::Template';

my $http_regex = qr/^http|\//;
sub process{
    my ( $self, $c ) = @_;

    my $scripts;
    if ( $c->stash->{'inline'} ){
        $scripts = $c->stash->{'inline'};
        delete $c->stash->{'inline'};
    } else {
        $scripts = $c->stash->{'js_includes'};
    }

    my $js_inc_done = {};

    my $out;
    foreach my $js_include ( @{$scripts} ){
        if ( !$js_inc_done->{$js_include} ){
            if ( $js_include !~ /$http_regex/ ){
#replace @ with / so we can get the file mod time
                my $js_file = $js_include;
                $js_file =~ s|@|/|;

                my $m_time = $c->view->file_mtime("@{[ $c->path_to('root') ]}@{[ $c->stash->{'theme_settings'}->{'js_path'} ]}/${js_file}.js");
                $out .= qq\<script type="text/javascript" src="@{[ $c->config->{'jscache_path'} ]}/@{[ $c->stash->{'theme_settings'}->{'name'} ]}_${js_include}_${m_time}.js"></script>\;

            } else {
                $out .= qq\
                <script type="text/javascript" src="${js_include}"></script>\;
            }
            $js_inc_done->{$js_include} = 1;
        }
    }

    return $out;
}

1;

package TAN::View::Template::Classic::Lib::Config;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $theme_settings = $c->stash->{'theme_settings'};
    my $path =$c->config->{'static_path'} . "/themes/@{[ $theme_settings->{'name'} ]}";
    $c->stash->{'theme_settings'} = {
        'name' => 'classic',
        'css_path' => "${path}/css",
        'js_path' => "${path}/js",
        'image_path' => "${path}/images",
        %{$theme_settings},
    };

    $c->stash->{'js_includes'} = [
        'mootools-1-2-5-core-nc', 
        "mootools-more",
        'TAN',
        'menu',
        'recent-comments'
    ];
    
    $c->stash->{'css_includes'} = [
       'shared',
    ];
    
    if ( !defined($c->stash->{'page_title'}) ){
        $c->stash->{'page_title'} = 'Social News For Internet Pirates';
    }
    $c->stash->{'page_meta_description'} ||= 'Social News For Internet Pirates';
    $c->stash->{'page_keywords'} = 'strange pirate news community comments english social fun jokes videos pictures share sharing lol lolz funny humour humor';
}

1;

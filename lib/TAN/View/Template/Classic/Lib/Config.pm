package TAN::View::Template::Classic::Lib::Config;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $theme_settings = $c->stash->{'theme_settings'};
    $c->stash->{'theme_settings'} = {
        'name' => 'classic',
        'display_name' => 'Classic',
        'description' => 'The classic theme v2',
        'css_path' => "$theme_settings.path/css",
        'js_path' => "@{[ $theme_settings->{'path'} ]}/js",
        'image_path' => "@{[ $theme_settings->{'path'} ]}/images",
        %{$theme_settings},
    };

    $c->stash->{'js_includes'} = [
        'mootools-1-2-4-core-nc', 
        "mootools-1-2-4-4-more",
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
    $c->stash->{'page_meta_description'} = 'Social News For Internet Pirates';
    $c->stash->{'page_keywords'} = 'strange pirate news community comments english social fun jokes videos pictures share sharing lol lolz funny humour humor';
}

1;

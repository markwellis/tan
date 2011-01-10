package TAN::View::Template::Classic::Lib::Editor;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $editor ) = @_;

    my $edheight = defined($editor->{'height'}) ? $editor->{'height'} : '300px';
    my $edwidth = defined($editor->{'width'}) ? $editor->{'width'} : '100%';
    my $edname = defined($editor->{'name'}) ? $editor->{'name'} : 'editor';

    my $out = qq\
        <textarea class="${edname}" style="height:${edheight};width:${edwidth}" id="${edname}" name="${edname}" rows="80" cols="20">@{[ 
            $c->view->html($editor->{'value'}) || '' 
        ]}</textarea>\;

    if ( 
        ( $c->req->user_agent =~ /iPhone/ ) 
        || ( $c->req->user_agent =~ /Android/ )
    ){
    #tinymce isn't compatable with iPhone or Android
        #remove comment from js since comment.js references tinymce
        my @js_includes;
        foreach my $js_include ( @{ $c->stash->{'js_includes'} } ){
            if ( $js_include ne 'comment' ){
                push( @js_includes, $js_include );
            }
        }
        $c->stash->{'js_includes'} = \@js_includes;
        return $out;
    }

    push(@{$c->stash->{'js_includes'}}, '/static/tiny_mce/tiny_mce.js?r=10');
    push(@{$c->stash->{'js_includes'}}, 'tiny-mce-config');

    return qq\
        ${out}
        <script type="text/javascript">
        //<![CDATA[
            var tiny_mce_config;
            tiny_mce_config['width'] = "${edwidth}";
            tiny_mce_config['height'] = "${edheight}";
            tiny_mce_config['editor_selector'] = "${edname}";
            tiny_mce_config['content_css'] = "@{[ $c->stash->{'theme_settings'}->{'css_path'} ]}/editor.css?r=1";
            tiny_mce_config['relative_urls'] = false;

            tinyMCE.init( tiny_mce_config );
        //]]>
        </script>\;
}

1;

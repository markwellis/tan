package TAN::View::Template::Classic::Submit::TagThumbBrowser;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    if ( $c->stash->{'location'} ne 'picture' ){
        push(@{$c->stash->{'js_includes'}}, 'tag-thumbs');
    }

    my $object = $c->stash->{'object'};

    print qq\
        <label for="tags">Tags</label>
        <input type="text" name="tags" id="tags" class="text_input full_width" value="@{[
            $object ?
                map($_->tag, $object->tags->all)
            : 
                ''
        ]}"/>\;

    if ( $c->stash->{'location'} ne 'picture' ){
        print '<a href="" class="refresh_thumbs right">Refresh</a>';
    }

    print qq\
        <br />
        <div id="thumb_tags">
            e.g.
            <ul style="margin-left:25px"> 
                <li>nasa moon space</li>
                <li>car mini cooper classic</li>
            </ul>
        </div>\;

    if ( $object ){
        print qq#
            <script type="text/javascript">
                get_thumbs( \$('cat').value );
            </script>#;
    }
}

1;

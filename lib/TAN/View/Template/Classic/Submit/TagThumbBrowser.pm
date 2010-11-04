package TAN::View::Template::Classic::Submit::TagThumbBrowser;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    if ( $c->stash->{'location'} ne 'picture' ){
        push(@{$c->stash->{'js_includes'}}, 'tag-thumbs');
    }

    my $object = $c->stash->{'object'} || $c->flash->{'object'};

    my @tags;
    if ( defined(($object)) ){
        if ( ref($object) eq 'HASH' ){
            @tags = map($_->{'tag'}, @{$object->{'tags'}});
        } else {
            @tags = map($_->tag, $object->tags->all);
        }
    }

    my $out = qq\
        <label for="tags">Tags</label>
        <input type="text" name="tags" id="tags" class="text_input full_width" value="@{[
            scalar(@tags) ?
                join(' ', @tags)
            : 
                ''
        ]}"/>\;

    if ( $c->stash->{'location'} ne 'picture' ){
        $out .= '<a href="" class="refresh_thumbs right">Refresh</a>';
    }

    $out .= qq\
        <br />
        <div id="thumb_tags">
            e.g.
            <ul style="margin-left:25px"> 
                <li>nasa moon space</li>
                <li>car mini cooper classic</li>
            </ul>
        </div>\;

    if ( $object ){
        $out .= qq#
            <script type="text/javascript">
                get_thumbs( \$('picture_id').value );
            </script>#;
    }

    return $out;
}

1;

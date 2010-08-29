package TAN::View::Template::Classic::Submit::Picture;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'} || $c->flash->{'object'};
    my ( $title, $pic_url, $description, $nsfw );

    if ( defined($object) ){
        if ( ref($object) eq 'HASH' ){
            $title = $object->{'picture'}->{'title'};
            $pic_url = $object->{'picture'}->{'pic_url'};
            $description = $object->{'picture'}->{'description'};
            $nsfw = $object->{'nsfw'};
        } else {
            $title = $object->picture->title;
            $description = $object->picture->description;
            $nsfw = $object->nsfw;
        }
    }

    my $out = qq\
        <form action="post" enctype="multipart/form-data" id="submit_form" method="post">
            <fieldset>
                <input type="hidden" name="MAX_FILE_SIZE" value="@{[ $c->config->{"Model::FetchImage"}->{'max_filesize'} ]}" />
                <ul>
                    <li>
                        <label for="title">Title</label>
                    </li>
                    <li>
                        <input type="text" name="title" id="title" value="@{[ 
                            $title ? 
                                $c->view->html($title) 
                            : 
                                '' 
                        ]}"/>
                    </li>\;

    if ( defined($object) && $c->stash->{'edit'} && $object->picture->id ){
        my $md = $object->picture->id - ($object->picture->id % 1000);
        $out .= qq\
            <li>
                <img alt="@{[ $object->picture->id ]}" src="@{[ $c->config->{'thumb_path'} ]}/${md}/@{[ $object->picture->id ]}/600"/>
            </li>\;
    } else {
        $out .= qq\
            <li>
                <label for="pic">Upload File</label>
            </li>
            <li>
                <input type="file" name="pic" id="pic" />
            </li>
            <li>
                <label for="pic_url">Remote Upload</label>
            </li>
            <li>
                <input type="text" name="pic_url" id="pic_url" value="@{[ 
                    $pic_url ?
                        $c->view->html($pic_url)
                    : ''
                ]}"/>
            </li>\;
    }

    $out .= qq\
            <li>
                <label for="pdescription">Description (optional)</label>
            </li>
            <li>
                <textarea cols="1" rows="5" name="pdescription" id="pdescription">@{[ 
                    $description ? 
                        $c->view->html($description)
                    : ''
                ]}</textarea>
            </li>
            <li>
                <label for="nsfw">Not Safe for Work?</label>
            </li>
            <li>
                <input type="checkbox" name="nsfw" id="nsfw" @{[ ( $nsfw && ($nsfw eq 'Y') ) ? 'checked="checked"' : '' ]}/>
            </li>
        </ul>
                @{[ $c->view->template('Submit::TagThumbBrowser') ]}
                <input type="submit" value="Submit Picture"/>
            </fieldset>
        </form>\;

    return $out;
}

1;

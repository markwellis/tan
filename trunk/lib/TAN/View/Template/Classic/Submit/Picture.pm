package TAN::View::Template::Classic::Submit::Picture;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'};
    print qq\
        <form action="post" enctype="multipart/form-data" id="submit_form" method="post">
            <fieldset>
                <input type="hidden" name="MAX_FILE_SIZE" value="@{[ $c->config->{"Model::FetchImage"}->{'max_filesize'} ]}" />
                <ul>
                    <li>
                        <label for="title">Title</label>
                    </li>
                    <li>
                        <input type="text" name="title" id="title" value="@{[ 
                            $object ? 
                                $c->view->html($object->picture->title) 
                            : 
                                '' 
                        ]}"/>
                    </li>\;

    if ( $object && $object->picture->id ){
        my $md = $object->picture->id - ($object->picture->id % 1000);
        print qq\
            <li>
                <img alt="@{[ $object->picture->id ]}" src="@{[ $c->config->{'thumb_path'} ]}/${md}/@{[ $object->picture->id ]}/600"/>
            </li>\;
    } else {
        print qq\
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
                    $object ?
                        $object->picture->pic_url 
                    : ''
                ]}"/>
            </li>\;
    }

    print qq\
            <li>
                <label for="pdescription">Description (optional)</label>
            </li>
            <li>
                <textarea cols="1" rows="5" name="pdescription" id="pdescription">@{[ 
                    $object ? 
                        $c->view->html($object->picture->description)
                    : ''
                ]}</textarea>
            </li>
            <li>
                <label for="nsfw">Not Safe for Work?</label>
            </li>
            <li>
                <input type="checkbox" name="nsfw" id="nsfw" @{[ ($object && ($object->nsfw eq 'Y')) ? 'checked="checked"' : '' ]}/>
            </li>
        </ul>\;

    $c->view->template('Submit::TagThumbBrowser');

    print qq\
                <input type="submit" value="Submit Picture"/>
            </fieldset>
        </form>\;
}

1;

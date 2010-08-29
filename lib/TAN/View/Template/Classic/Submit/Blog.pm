package TAN::View::Template::Classic::Submit::Blog;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'} || $c->flash->{'object'};
    my ( $title, $details, $description, $picture_id );

    if ( defined($object) ){
        if ( ref($object) eq 'HASH' ){
            $picture_id = $object->{'blog'}->{'picture_id'};
            $title = $object->{'blog'}->{'title'};
            $details = $object->{'blog'}->{'details'};
            $description = $object->{'blog'}->{'description'};
        } else {
            $picture_id = $object->blog->picture_id;
            $title = $object->blog->title;
            $description = $object->blog->description;
            $details = $object->blog->details_nobb;
        }
    }

    return qq\
        <form action="post" id="submit_form" method="post">
            <fieldset>
                <ul>
                    <li>
                        <input type="hidden" id="cat" name="cat" value="@{[
                            $picture_id ? 
                                $c->view->html($picture_id)
                            :
                                ''
                        ]}" />
                        <label for="title">Title</label>
                    </li>
                    <li>
                        <input type="text" name="title" id="title" value="@{[ 
                            $title ? 
                                $c->view->html($title) 
                            : 
                                '' 
                        ]}" />
                    </li>
                    <li>
                        <label for="description">Description</label>
                    </li>
                    <li>
                        <textarea cols="1" rows="5" name="description" id="description" >@{[
                            $description ? 
                                $c->view->html($description)
                            :
                                ''
                        ]}</textarea><br/>
                    </li>
                    <li>
                        <label for="blogmain">Blog</label>
                    </li>
                    <li>
                    @{[ 
                        $c->view->template('Lib::Editor', {
                            'name' => "blogmain",
                            'value' => $details ? $details : '',
                            'height' => '600px',
                        })
                    ]}
                    </li>
                </ul>
                @{[ $c->view->template('Submit::TagThumbBrowser') ]}
                <input type="submit" value="Submit Blog"/>
            </fieldset>
        </form>\;
}

1;

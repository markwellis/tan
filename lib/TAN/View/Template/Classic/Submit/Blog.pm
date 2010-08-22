package TAN::View::Template::Classic::Submit::Blog;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'};

    return qq\
        <form action="post" id="submit_form" method="post">
            <fieldset>
                <ul>
                    <li>
                        <input type="hidden" id="cat" name="cat" value="@{[
                            $object ? 
                                $object->blog->picture_id
                            :
                                ''
                        ]}" />
                        <label for="title">Title</label>
                    </li>
                    <li>
                        <input type="text" name="title" id="title" value="@{[ 
                            $object ? 
                                $c->view->html($object->blog->title) 
                            : 
                                '' 
                        ]}" />
                    </li>
                    <li>
                        <label for="description">Description</label>
                    </li>
                    <li>
                        <textarea cols="1" rows="5" name="description" id="description" >@{[
                            $object ? 
                                $c->view->html($object->blog->description)
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
                            'value' => $object ? $object->blog->details_nobb : '',
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

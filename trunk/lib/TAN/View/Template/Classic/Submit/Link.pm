package TAN::View::Template::Classic::Submit::Link;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'};

    print qq\
        <form action="post" id="submit_form" method="post">
            <fieldset>
                <ul>
                    <li>
                        <input type="hidden" id="cat" name="cat" value="@{[
                            $object ? 
                                $object->link->picture_id
                            :
                                ''
                        ]}" />
                        <label for="url">Title</label>
                    </li>
                    <li>
                        <input type="text" name="title" id="title" value="@{[ 
                            $object ? 
                                $c->view->html($object->link->title) 
                            : 
                                '' 
                        ]}"/>
                    </li>
                    <li>
                        <label for='url'>Url</label>
                    </li>
                    <li>
                        <input type="text" name="url" id="url" value="@{[ 
                            $object ? 
                                $c->view->html($object->link->url) 
                            : 
                                '' 
                        ]}" />
                    </li>
                    <li>
                        <label for="description">Description</label>
                    </li>
                    <li>
                        <textarea cols="1" rows="5" name="description" id="description">@{[ 
                            $object ? 
                                $c->view->html($object->link->description) 
                            : 
                                '' 
                        ]}</textarea><br/>
                    </li>
                </ul>\;

    $c->view->template('Submit::TagThumbBrowser');

    print qq\
                <input type="submit" value="Submit Link"/>
            </fieldset>
        </form>\;
}

1;

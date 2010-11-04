package TAN::View::Template::Classic::Submit::Link;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'} || $c->flash->{'object'};
    my ( $title, $url, $description, $picture_id );

    if ( defined($object) ){
        if ( ref($object) eq 'HASH' ){
            $picture_id = $object->{'link'}->{'picture_id'};
            $title = $object->{'link'}->{'title'};
            $url = $object->{'link'}->{'url'};
            $description = $object->{'link'}->{'description'};
        } else {
            $picture_id = $object->link->picture_id;
            $title = $object->link->title;
            $description = $object->link->description;
            $url = $object->link->url;
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
                        <label for="url">Title</label>
                    </li>
                    <li>
                        <input type="text" name="title" id="title" value="@{[ 
                            $title ? 
                                $c->view->html($title) 
                            : 
                                '' 
                        ]}"/>
                    </li>
                    <li>
                        <label for='url'>Url</label>
                    </li>
                    <li>
                        <input type="text" name="url" id="url" value="@{[ 
                            $url ?  
                                $c->view->html($url) 
                            : 
                                '' 
                        ]}" />
                    </li>
                    <li>
                        <label for="description">Description</label>
                    </li>
                    <li>
                        <textarea cols="1" rows="5" name="description" id="description">@{[ 
                            $description ? 
                                $c->view->html($description) 
                            : 
                                '' 
                        ]}</textarea><br/>
                    </li>
                </ul>
                @{[ $c->view->template('Submit::TagThumbBrowser') ]}
                <input type="submit" value="Submit Link"/>
            </fieldset>
        </form>\;
}

1;

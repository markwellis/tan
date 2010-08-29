package TAN::View::Template::Classic::Submit::Poll;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'} || $c->flash->{'object'};
    my ( $title, $description, $picture_id );
    my @answers = (undef, undef);

    if ( defined($object) ){
        if ( ref($object) eq 'HASH' ){
            $picture_id = $object->{'poll'}->{'picture_id'};
            $title = $object->{'poll'}->{'title'};
            $description = $object->{'poll'}->{'description'};
            @answers = map($_->{'answer'}, @{ $object->{'poll'}->{'answers'} });
        } else {
            $picture_id = $object->poll->picture_id;
            $title = $object->poll->title;
            $description = $object->poll->description;
            @answers = map($_->answer, $object->poll->answers->all);
            if ( scalar(@answers) == 1 ){
                push(@answers, undef);
            }
        }
    }

    my $out = qq\
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
                    <li>
                        <label for="days">End in this many days</label>
                    </li>
                    <li>
                        <input type="text" name="days" id="days" value="3" @{[ $c->stash->{'edit'} ? 'disabled="disabled"' : '' ]}/>
                    </li>\;

        my $loop = 0;
        foreach my $answer ( @answers ){
            $out .= qq\
                <li>
                    <label for="answer${loop}">Answer ${loop}</label>
                </li>
                <li>
                    <input type="text" name="answers" id="answer${loop}" class="TAN-poll-answer" value="@{[ $answer ? $answer : '' ]}"/>
                </li>\;
            ++$loop;
        }

        $out .= qq\
                <li>
                    <a href="#" class="TAN-poll-submit-add-more">Add another</a>
                </li>
            </ul>
            @{[ $c->view->template('Submit::TagThumbBrowser') ]}
            <input type="submit" value="Submit Poll"/>
        </fieldset>
    </form>\;

    return $out;
}

1;

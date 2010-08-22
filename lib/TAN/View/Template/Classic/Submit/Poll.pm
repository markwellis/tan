package TAN::View::Template::Classic::Submit::Poll;

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
                                $object->poll->picture_id
                            : 
                                '' 
                        ]}" />
                        <label for="url">Title</label>
                    </li>
                    <li>
                        <input type="text" name="title" id="title" value="@{[ 
                            $object ? 
                                $c->view->html($object->poll->title) 
                            : 
                                '' 
                        ]}"/>
                    </li>
                    <li>
                        <label for="description">Description</label>
                    </li>
                    <li>
                        <textarea cols="1" rows="5" name="description" id="description">@{[ 
                            $object ? 
                                $c->view->html($object->poll->description) 
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

            my @answers;
            if ( $object ){
                @answers = $object->poll->answers->all;
                
                if ( scalar($answers) == 1 ){
                    push(@answers, undef);
                }
            } else {
                @answers = (undef, undef);
            }

            my $loop = 0;
            foreach my $answer ( @answers ){
                print qq\
                    <li>
                        <label for="answer${loop}">Answer ${loop}</label>
                    </li>
                    <li>
                        <input type="text" name="answers" id="answer${loop}" class="TAN-poll-answer" value="@{[ $answer ? $answer->answer : '' ]}"/>
                    </li>\;
                ++$loop;
            }

            print qq\
                    <li>
                        <a href="#" class="TAN-poll-submit-add-more">Add another</a>
                    </li>
                </ul>\;

    $c->view->template('Submit::TagThumbBrowser');

    print qq\
                <input type="submit" value="Submit Poll"/>
            </fieldset>
        </form>\;
}

1;

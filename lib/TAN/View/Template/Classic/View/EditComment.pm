package TAN::View::Template::Classic::View::EditComment;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;
    
    my $comment_id = $c->stash->{'comment_id'};
    print qq\
        <form method="post" action="/@{[ $c->req->path ]}">
            <fieldset>\;
    
    $c->view->template('Lib::Editor', {
        'name' => "edit_comment_${comment_id}",
        'value' => $c->stash->{'comment'},
        'height' => '600px',
    });

    print qq\
                <input type="submit" value="Edit" id="edit${comment_id}" name="edit${comment_id}" />
                <input type="submit" value="Delete" id="delete${comment_id}" name="delete${comment_id}" />
            </fieldset>
        </form>\;
}

1;

package TAN::View::Template::Classic::View::Comments;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    print qq\<div class="TAN-comment_wrapper">\;
    
    if ( $c->stash->{'object'}->comments ){
        foreach my $comment ( ($c->stash->{'comments'}) ){
            $c->view->template('View::Comment', $comment);
        }

        push(@{$c->stash->{'js_includes'}}, 'nsfw-comments');
        push(@{$c->stash->{'js_includes'}}, 'comment');
    }
    print '</div>';

    print qq\
        <form id="comment_form" action="_comment" method="post">
        <fieldset>\;

    $c->view->template('Lib::Editor', {
        'name' => "comment",
        'height' => '300px',
    });

    print qq\
            <br />
            <input type="submit" value="Comment" id="submit_comment" />
        </fieldset>
    </form>\;
}

1;
package TAN::View::Template::Classic::View;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'view');
    push(@{$c->stash->{'js_includes'}}, 'comment');

    my $object = $c->stash->{'object'};

    if ( $c->stash->{'location'} eq 'poll' ){
        $c->stash->{'voted'} = ($c->user_exists) ? $object->poll->voted($c->user->id) : undef;
        $c->stash->{'ends'} = $object->poll->ends;

        if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
            push(@{$c->stash->{'js_includes'}}, 'poll');
        }
    }

    my $out = qq\
    <ul class="TAN-inside">
        <li class="TAN-news">\;

    $c->stash->{'article'} = 1;
    if ( $object->type eq 'picture' ){
        $out .= $c->view->template('View::Picture');
    } else {
        $out .= $c->view->template('Lib::Object');
    }

    $out .= qq\
        </li>
        <li class="TAN-news" id="comments">
            @{[ $c->view->template('View::Comments') ]}
        </li>
    </ul>\;
}

1;

package TAN::View::Template::Classic::View::EditComment;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;
    
    my $comment_id = $c->stash->{'comment'}->id;
    my $out = qq\
        <form method="post" action="/@{[ $c->req->path ]}">
            <fieldset>
                @{[    
                    $c->view->template('Lib::Editor', {
                        'name' => "edit_comment_${comment_id}",
                        'value' => $c->stash->{'comment'}->comment_nobb,
                        'height' => '600px',
                    })
                ]}\;

    if ( 
        $c->check_user_roles(qw/edit_comment/) 
        && ( $c->stash->{'comment'}->user->id != $c->user->id )
    ){
        $out .= qq#<input type="hidden" name="_edit-reason" id="_edit-reason" />#;
    }

    $out .= qq\
                <input type="submit" value="Edit" id="edit${comment_id}" name="edit${comment_id}" />
                <input type="submit" value="Delete" id="delete${comment_id}" name="delete${comment_id}" />
            </fieldset>
        </form>\;
}

__PACKAGE__->meta->make_immutable;

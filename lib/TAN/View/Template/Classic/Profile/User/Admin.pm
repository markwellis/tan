package TAN::View::Template::Classic::Profile::User::Admin;
use Moose;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

#change username
#ban
#unban
#remove avatar

    return qq\
        <form action="admin">
            <fieldset>
                <ul>
                    <li>
                        <h3>Delete all</h3>
                    </li>
                    <li>
                        <input type="submit" name="delete" value="comments" />
                    </li>
                    <li>
                        <input type="submit" name="delete" value="links" />
                    </li>
                    <li>
                        <input type="submit" name="delete" value="blogs" />
                    </li>
                    <li>
                        <input type="submit" name="delete" value="pictures" />
                    </li>
                    <li>
                        <input type="submit" name="delete" value="polls" />
                    </li>
                </ul>
            </fieldset>
        </form>\;
}

__PACKAGE__->meta->make_immutable;

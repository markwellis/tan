package TAN::View::Template::Classic::AdminLog;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'AdminLog');

    my $out = qq\<ul class="TAN-inside">
        <li>
            <table>
                <tr>
                    <th>Action</th>
                    <th>Admin</th>
                    <th>Username</th>
                    <th>When</th>
                    <th>Reason</th>
                </tr>\;

        foreach my $admin_log ( $c->stash->{'admin_logs'}->all ){
            $out .= 
                qq\<tr>
                    <td class="TAN-adminlog-action">
                        <a href="view/@{[ $admin_log->log_id ]}/">@{[ $admin_log->action ]}</a>
                    </td>
                    <td class="TAN-adminlog-admin">
                        <a href="@{[ $admin_log->admin->profile_url ]}">@{[ $admin_log->admin->username ]}</a>
                    </td>
                    <td class="TAN-adminlog-user">
                        <a href="@{[ $admin_log->user->profile_url ]}">@{[ $admin_log->user->username ]}</a>
                    </td>
                    <td class="TAN-adminlog-created">
                        @{[ $admin_log->created ]} ago
                    </td>
                    <td class="TAN-adminlog-reason">
                        @{[ $c->view->html( $admin_log->reason ) ]}
                    </td>
                </tr>\;
        }

    $out .= qq\</table>
        </li>
    </ul>\;

    $out .= $c->view->template( 'Index::Pagination', $c->stash->{'admin_logs'}->pager );

    return $out;
}
__PACKAGE__->meta->make_immutable;

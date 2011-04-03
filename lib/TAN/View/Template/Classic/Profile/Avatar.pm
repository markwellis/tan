package TAN::View::Template::Classic::Profile::Avatar;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'view');
    push(@{$c->stash->{'css_includes'}}, 'Profile@Avatar');

    push(@{$c->stash->{'js_includes'}}, 'Lasso');
    push(@{$c->stash->{'js_includes'}}, 'Lasso-Crop');
    push(@{$c->stash->{'js_includes'}}, 'Profile@Avatar');

    my $out = '<ul class="TAN-inside">';
    my $avatar_http = $c->user->avatar($c);

    if ( !$c->stash->{'crop'} ){
    # upload page
        $out .= qq\
            <li class="TAN-news left" >
                <img alt="@{[ $c->view->html($c->user->username) ]}" src="${avatar_http}" class="avatar">
            </li>
            <li class="TAN-news">
                <h2>
                    Upload avatar
                </h2>
                <p>
                    Keep your avatar safe for work
                </p>

                <form method="post" action="/profile/_avatar/upload" enctype="multipart/form-data" id="crop_form">
                    <fieldset>
                        <input type="file" name="avatar" id="avatar" />
                        <input type="submit" value="Upload" />
                    </fieldset>
                </form>
            </li>\;
    } else {
    # crop page
        $avatar_http =~ s/\?/\.no_crop\?/;
        $out .= qq\
            <li class="TAN-news">
                <h2>
                    Crop avatar
                </h2>
                <p>
                    Please select the area you wish to have as your avatar
                </p>
                <img src="${avatar_http}" id="cropper"/>

                <form method="post" action="/profile/_avatar/crop" id="crop_form">
                    <fieldset>
                        <input type="hidden" name="cords" id="cords" />
                        <input type="submit" value="Crop"/>
                    </fieldset>
                </form>        
            </li>\
    }
    $out .= '</ul>';

    return $out;
}

1;

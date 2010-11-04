package TAN::View::Template::Classic::Submit::Link;

use base 'Catalyst::View::Perl::Template';

use feature qw/switch/;

sub process{
    my ( $self, $c ) = @_;

    my $module = $c->model('Submit')->modules->{'link'};

    return undef if !$module;

    my $config = $module->config;

    # this doesn't really cut it, coz we need to produce javascript
    # as well so that we can validate input stuff client side, or maybe thats 
    # another function?
    my $output;
    foreach my $key ( sort(keys(%{$config})) ){
# HTMLENTITTIES!!!!!!! // heh heh titties, but cereal y'all
        if ( $config->{ $key }->{'type'} ne 'hidden' ){
            $output .= qq\<label for="${key}">@{[ ucfirst($key) ]}</label>\;
        }
        given ($config->{ $key }->{'type'}){
            when ('textarea'){
                $output .= qq\<textarea name="${key}" id="${key}"></textarea>\;
            };
            default {
                $output .= qq\<input type="${_}" name="${key}" id="${key}" />\;
            };
        }
    }

    return qq\
        <form action="post" id="submit_form" method="post">
            <fieldset>
            ${output}<br /><br />
                <ul>
                    <li>
                        <input type="hidden" id="type" name="type" value="link" />
                        <input type="hidden" id="picture_id" name="picture_id" value="@{[
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

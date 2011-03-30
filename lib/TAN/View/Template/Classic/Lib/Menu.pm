package TAN::View::Template::Classic::Lib::Menu;

use base 'Catalyst::View::Perl::Template';
use Tie::Hash::Indexed;

sub process{
    my ( $self, $c ) = @_;

    tie my %menu_tabs, 'Tie::Hash::Indexed';

    $menu_tabs{'All'} = 'all';

    foreach my $module ( @{ $c->model('Submit')->menu_items } ){
        $menu_tabs{ ucfirst("${module}s") } = $module;
    }

    my $out = qq\
    <div class="TAN-menu left">
        <ul class="TAN-menu-tab-holder">\;
    
    my $loop = 0;
    my $size = scalar(keys(%menu_tabs)) - 1;
    my $type = $c->stash->{'type'};

    foreach my $key ( keys(%menu_tabs) ){
        $value = $menu_tabs{$key};
        $out .= qq\
            <li@{[ ($loop == $size) ? ' class="TAN-menu-last"' : '' ]}>
                <a class="TAN-menu-tab TAN-type-${value} @{[ ($type eq $value) ? "TAN-menu-tab-@{[ $type ]}-selected" : '' ]}" href="/index/${value}/0/">${key}</a>
            </li>\;
        ++$loop;
    }
    $out .= '</ul>';
    foreach my $value ( values(%menu_tabs) ){
        $out .= qq\
        <ul class="TAN-menu-${value}" @{[ ($type eq $value) ? 'style="display:block"' : '' ]}>\;

        if ( $value ne 'all' ){
            $out .= qq\
                <li>
                    <a href="/submit/${value}/">Submit</a>
                </li>\;
        }
        $out .= qq\
            <li>
                <a href="/random/${value}/">Random</a>
            </li>
            <li>
                <a href="/index/${value}/0/" @{[ 
                    ( ($type eq $value) && (defined($c->stash->{'upcoming'}) && $c->stash->{'upcoming'} == 0) ) ? 
                        qq#class="TAN-menu-tab-${type}-selected"# 
                    : 
                        '' 
                    ]}>Promoted</a>
            </li>
            <li class="TAN-menu-last">
                <a href="/index/${value}/1/" @{[
                    ( ($type eq $value) && ($c->stash->{'upcoming'}) ) ? 
                        qq#class="TAN-menu-tab-${type}-selected"# 
                    :
                        '' 
                    ]}>Upcoming</a>
            </li>
        </ul>\;
    }
    $out .= <<"END";
    </div>
    <script type="text/javascript">
    //<![CDATA[
        selected_menu_type = '${type}';
    //]]>
    </script>
END

    return $out;
}

1;

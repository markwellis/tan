package TAN::View::Template::Classic::Lib::Wrapper;

use Time::HiRes qw/time/;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $content ) = @_;

    my $page_title = $c->view->html($c->stash->{'page_title'});
    if ( $page_title ){
        $page_title = "${page_title} - ";
    }

    
    my $rss_url;

    if ( $c->stash->{'can_rss'} ){
        $rss_url = $c->view->url($c->req->uri, %{$c->req->params}, 'rss' => 1) ;
    }

    return <<"END";
<!DOCTYPE  html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>${page_title}This Aint News</title>
            <meta name="Description" content="@{[ $c->view->html($c->stash->{'page_meta_description'}) ]}"/>
            <meta name="keywords" content="@{[ $c->stash->{'page_keywords'} ]}"/>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            @{[ $c->view->template('Lib::CssIncludes') ]}
            <link rel="shortcut icon" href="/static/favicon.ico" />
            <link rel="search" type="application/opensearchdescription+xml" title="TAN Search" href="/static/opensearchplugin.xml" />
            @{[
                $c->stash->{'can_rss'} ?
                    qq#<link rel="alternate" type="application/rss+xml" title="RSS" href="@{[ $c->view->url($c->req->uri, %{$c->req->params}, 'rss' => 1) ]}" />#
                :
                    ''
            ]}

            <script type="text/javascript">
            //<![CDATA[
                var _gaq = _gaq || [];
                _gaq.push(['_setAccount', 'UA-17305684-1']);
                _gaq.push(['_trackPageview']);

                (function() {
                    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                })();
            //]]>
            </script>
        </head>
        <body>
        @{[ $c->view->template('Lib::JsIncludes') ]}
        <div class="TAN-header">
            <h1 class="TAN-logo">
                <a title="This Aint News" href="/index/all/0/">This Aint News</a>
            </h1>
            <div class="TAN-menu-top right">
                <form class="right" method="post" action="https://www.paypal.com/cgi-bin/webscr">
                    <fieldset>
                        <input type="hidden" value="_xclick" name="cmd" />
                        <input type="hidden" value="donate\@thisaintnews.com" name="business" />
                        <input type="hidden" value="TAN Donation" name="item_name" />
                        <input type="hidden" value="mrbig4545" name="item_number" />
                        <input type="hidden" value="GBP" name="currency_code" />
                        <input type="hidden" value="0" name="tax" />
                        <input type="image" alt="Donate" name="submit" src="/static/images/paypal.gif" />
                    </fieldset>
                </form>
                <p>
                    @{[ 
                    $c->stash->{'can_rss'} ?
                        qq#<a href="${rss_url}"><img src="/static/images/rss.png" alt="rss" class="TAN-rss-icon" /></a> | #
                    : 
                        ''
                    ]}
                    <a href="http://stats.thisaintnews.com">Stats</a> |
                    <a class="mibbit" href="/chat/">Chat</a>
                    @{[ $c->user_exists ? '| <a href="/login/logout/">Logout</a>' : '' ]}
                </p>
                <p>
                @{[ 
                $c->user_exists ? 
                    qq#<a href="/profile/@{[ $c->view('Perl')->html($c->user->username) ]}/">Profile</a> | #
                : 
                    '<a href="/login/">Login/Register</a> | ' 
                ]}
                    <a href="/filter/" class="nsfw_filter">@{[ $c->nsfw ? 'Enable' : 'Disable' ]} filter</a> | 
                    <a href="/faq/">FAQ</a>                    
                </p>
                <form class="TAN-menu-top-search" action="/search/" method="get">
                    <fieldset>
                        <input type="text" size="31" name="q" value="@{[ $c->view('Perl')->html($c->req->param('q')) ]}"/>
                        <input type="submit" value="Search" />
                    </fieldset>
                </form>
            </div>
            <div class="TAN-menu-ad-holder">
                @{[ $c->view->template('Lib::Menu') ]}
                @{[ $c->view->template('Lib::Ad', 'top') ]}
            </div>
        </div>
        <div class="TAN-main">
            @{[ $c->view->template('Lib::RecentComments') ]}
            <div class="TAN-right-ads right">
                @{[ $c->view->template('Lib::Ad', 'right1') ]}
            </div>
        <script type="text/javascript">
        //<![CDATA[
            @{[ 
            defined($c->stash->{'message'}) ? 
                qq#window.addEvent('domready', function(){
                    TAN.alert("@{[ $c->view->html($c->view->trim($c->stash->{'message'})) ]}");
                    });#
            : '' 
            ]}

            var mibbit_nick = '@{[ $c->user_exists ? $c->user->username : 'n00b' ]}';
        //]]>
        </script>
        @{[
        defined($c->stash->{'message'}) ?
            qq#<noscript>
            <h1>@{[ $c->stash->{'message'} ]}</h1>
            </noscript>#
        : ''
        ]}
        ${content}
    </div>
    <div id="TAN-bottom"></div>
    <div class="TAN-footer">
        @{[ substr(time - $c->stash->{'start_time'}, 0, 4) ]} seconds,
        version @{[ $c->VERSION ]}
        <span class="right"><a href="#">Up</a>&#160;<a href="#TAN-bottom">Down</a></span>
    </div>
    </body>
</html>
END
}

1;

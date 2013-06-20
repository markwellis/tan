backend static {
    .host = "static.tan";
    .port = "8080";
}

backend trac {
    .host = "trac.tan";
    .port = "8080";
}

backend tan {
    .host = "tan.tan";
    .port = "8081";
}

import std;
#std.syslog(180, "RECV: " + req.http.host);

sub vcl_recv {
    remove req.http.X-Forwarded-For;
    set    req.http.X-Forwarded-For = client.ip;
    if ( req.http.host ~ "^trac\.(?:dev\.)?thisaintnews\.com$" ){
        set req.backend = trac;
    } else if ( req.http.host ~ "^(?:dev\.)?thisaintnews\.com$" ){
        if ( req.url !~ "^/static/" ){
            set req.backend = tan;
        } else {
            set req.backend = static;
        }
    } else {
    #pass if we're some other domain
        return(pass);
    }

    #ie6 can't handle gzip
    if (req.http.user-agent ~ "MSIE 6") {
        unset req.http.accept-encoding;
    }

    ## Force lookup if the request is a no-cache request from the client
    ## IE - shift-reload causes cache refresh - We may not want this in 
    ## production but useful during initial deployment and testing
#    if (req.http.Cache-Control ~ "no-cache") {
#        purge_url(req.url);
#    }

#leach protection
    if ( req.backend == static ){
        ## Cache based on file path - if it's in static, it probably 
        ## doesn't change much.
        if (req.request == "GET") {
            unset req.http.cookie;
            unset req.http.authorization;
            return(lookup);
        }

        if ( 
            req.url ~ "^/static/user/pics/.*$|^/static/cache/thumbs/.*$"
            && req.http.referer !~ "thisaintnews.com"
            && req.http.user-agent !~ "redditbot" #reddit bastards
            && req.http.user-agent !~ "googlebot"
            && req.http.user-agent !~ "facebookexternalhit"
            && req.url !~ "100\?rss=1$"
        ){
            set req.url = regsub(
                req.url,
                "^/static/user/pics/(.*)$|^/static/cache/thumbs/[0-9]+/([0-9]+)/[0-9]+.*$|^/thumb/[0-9]+/([0-9]+)/[0-9]+.*$",
                "/redirect/internal/\1\2\3"
            );
            return(pass);
        }
        
        if ( 
            req.url ~ "^/static/smilies/.*$"
            && req.http.referer !~ "thisaintnews.com"
        ){
            set req.url = regsub(
                req.url,
                "^.*$",
                "/images/blank.gif"
            );
            return(pass);
        }
    }

    if (
        ( req.backend == tan ) 
        && ( req.url ~ "^/favicon.ico$" )
    ){
        error 750;
    }

    ## Chances are that if we are receiving POST data, we don't want to cache 
    ## so we short circuit it here.
    if (req.request == "POST") {
        return(pass);
    }

    ## any unusual requests are passed through.
    if (req.request != "GET" &&
      req.request != "HEAD" &&
      req.request != "PUT" &&
      req.request != "POST" &&
      req.request != "TRACE" &&
      req.request != "OPTIONS" &&
      req.request != "DELETE") {
        # Non-RFC2616 or CONNECT which is weird. #
        return(pass);
    }

    ## if we have an authorization header, we definitely do not want to 
    ## cache 
    if (req.http.Authorization) {
        # Not cacheable by default #
        return(pass);
    }
    return(lookup);
}

sub vcl_fetch {
    #remove X-Catalyst header
    unset beresp.http.X-Catalyst;

    set beresp.do_gzip = true;

    ## Don't cache anything that is not a 20x response.  We don't want 
    ## to cache errors.  If you want to cache redirects, you 
    ## can set this to be higher than 300 (temporary redirects are 302)
    if (beresp.status >= 300) {
        return(hit_for_pass);
    }
    
    ## if varnish thinks it's not cachable, don't cache it.
    if (!beresp.ttl > 0s) {
        return(hit_for_pass);
    }
    
    ## if the object was trying to set a cookie, 
    ## it probably shouldn't be cached.
    if (beresp.http.Set-Cookie) {
        return(hit_for_pass);
    }
    
     ## if the object is specifically saying 'don't cache me' -  
     ## obey it.
     if(beresp.http.Pragma ~ "no-cache" ||  
        beresp.http.Cache-Control ~ "no-cache" || 
        beresp.http.Cache-Control ~ "private")  {   
    
        return(hit_for_pass);
    } 
    
    ## if the object is saying how long to cache it, you 
    ## can rely on the fact that it is cachable. 
    if (beresp.http.Cache-Control ~ "max-age") {
        unset beresp.http.Set-Cookie;
        return(deliver);
    }
    return(hit_for_pass);
}

sub vcl_error{
    if (obj.status == 750) {
        set obj.http.Location = "/static/favicon.ico";

        set obj.status = 301;
        return(deliver);
    }
}

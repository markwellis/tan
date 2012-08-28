#-e This is a basic VCL configuration file for varnish.  See the vcl(7)
#man page for details on VCL syntax and semantics.
#
#Default backend definition.  Set this to point to your content
#server.
#
backend tan {
    .host = "127.0.0.1";
    .port = "8080";
}

## http://www.catalystframework.org/calendar/2008/14

sub vcl_recv {

  # Add a unique header containing the client address
  remove req.http.X-Forwarded-For;
  set    req.http.X-Forwarded-For = client.ip;


    ## This sets the host header for your site - you should set this  
    ## because varnish takes host into consideration when caching.
    ## IE - www.foo.com and foo.com will be treated as separate by the cache
#    set req.http.host = "thisaintnews.com";

    ## set the backend to the Catalyst site
    set req.backend = tan;

    ## Force lookup if the request is a no-cache request from the client
    ## IE - shift-reload causes cache refresh - We may not want this in 
    ## production but useful during initial deployment and testing
#    if (req.http.Cache-Control ~ "no-cache") {
#        purge_url(req.url);
#    }

#leach protection
    if ( 
        req.url ~ "^/static/user/pics/.*$|^/static/cache/thumbs/.*$"
        && req.http.referer !~ "thisaintnews.com"
        && req.http.referer !~ "hub00.howmanykillings.com"
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
        && req.http.referer !~ "hub00.howmanykillings.com"
    ){
        set req.url = regsub(
            req.url,
            "^.*$",
            "/static/images/blank.gif"
        );
        return(pass);
    }

	if ( req.http.host !~ "^thisaintnews.com$" ){
		return(pass);
	}

    if (
    	req.url ~ "^/$" 
    	|| req.url ~ "^/index/(all|link|blog|picture)/[0-1]/[0-9]+/$"
	    || req.url ~ "^/(link|blog|picture)/[0-1]/[0-9]+/$"
    	|| req.url ~ "^/favicon.ico$"
    ){  
        error 750;
    } 
    
    ## Cache based on file path - if it's in /static/, it probably 
    ## doesn't change much.
    if (req.request == "GET" && req.url ~ "^/static/") {
        unset req.http.cookie;
        unset req.http.authorization;
        return(lookup);
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

    if (req.request == "GET" && req.url ~ "^/static" ) {

        unset beresp.http.Set-Cookie;

        ## We want to force a 30 minute timeout for static content so we
        ## set obj.ttl. If we do not set obj.ttl, though, it would default 
        ## to the varnish default, or the cache-control header if present. 
#        set obj.ttl = 30m;

        return(deliver);
    }
    
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
        if (req.url ~ "^/$"){
            set obj.http.Location = "/index/all/0/";
        } elsif (req.url ~ "^/index/(all|link|blog|picture)/[0-1]/[0-9]+/.*$"){
            set obj.http.Location = regsub(
                req.url,
                "^/index/(all|link|blog|picture)/([0-1])/([0-9]+)/.*$",
                "/index/\1/\2/\?page=\3"
            );
        } elsif (req.url ~ "^/(link|blog|picture)/[0-1]/[0-9]+/.*$"){
            set obj.http.Location = regsub(
                req.url,
                "^/(link|blog|picture)/([0-1])/([0-9]+)/.*$",
                "/index/\1/\2/\?page=\3"
            );
        } elsif (req.url ~ "^/favicon.ico"){
    		set obj.http.Location = "/static/favicon.ico";
        }

        set obj.status = 301;
        return(deliver);
    }
}

### END


#
#Below is a commented-out copy of the default VCL logic.  If you
#redefine any of these subroutines, the built-in logic will be
#appended to your code.
#
#sub vcl_recv {
#    if (req.request != "GET" &&
#      req.request != "HEAD" &&
#      req.request != "PUT" &&
 #     req.request != "POST" &&
 #     req.request != "TRACE" &&
 ##     req.request != "OPTIONS" &&
 #     req.request != "DELETE") {
 #       /* Non-RFC2616 or CONNECT which is weird. */
 #       return (pipe);
 #   }
 #   if (req.request != "GET" && req.request != "HEAD") {
 #       /* We only deal with GET and HEAD by default */
 #       return (pass);
 #   }
 #   if (req.http.Authorization || req.http.Cookie) {
 #       /* Not cacheable by default */
 #       return (pass);
 #   }
 #   return (lookup);
#}
#
#sub vcl_pipe {
#    # Note that only the first request to the backend will have
#    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
#    # have it set for all requests, make sure to have:
#    # set req.http.connection = "close";
#    # here.  It is not set by default as it might break some broken web
#    # applications, like IIS with NTLM authentication.
#    return (pipe);
#}
#
#sub vcl_pass {
#    return (pass);
#}
#
#sub vcl_hash {
#    set req.hash += req.url;
#    if (req.http.host) {
#        set req.hash += req.http.host;
#    } else {
#        set req.hash += server.ip;
#    }
#    return (hash);
#}
#
#sub vcl_hit {
#    if (!obj.cacheable) {
#        return (pass);
#    }
#    return (deliver);
#}
#
#sub vcl_miss {
#    return (fetch);
#}
#
#sub vcl_fetch {
#    if (!obj.cacheable) {
#        return (pass);
#    }
#    if (obj.http.Set-Cookie) {
#        return (pass);
#    }
#    set obj.prefetch =  -30s;
#    return (deliver);
#}
#
#sub vcl_deliver {
#    return (deliver);
#}
#
#sub vcl_discard {
#    /* XXX: Do not redefine vcl_discard{}, it is not yet supported */
#    return (discard);
#}
#
#sub vcl_prefetch {
#    /* XXX: Do not redefine vcl_prefetch{}, it is not yet supported */
#    return (fetch);
#}
#
#sub vcl_timeout {
#    /* XXX: Do not redefine vcl_timeout{}, it is not yet supported */
#    return (discard);
#}
#
#sub vcl_error {
#    set obj.http.Content-Type = "text/html; charset=utf-8";
#    synthetic {"
#<?xml version="1.0" encoding="utf-8"?>
#<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
# "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
#<html>
#  <head>
#    <title>"} obj.status " " obj.response {"</title>
#  </head>
#  <body>
#    <h1>Error "} obj.status " " obj.response {"</h1>
#    <p>"} obj.response {"</p>
#    <h3>Guru Meditation:</h3>
#    <p>XID: "} req.xid {"</p>
#    <address>
#       <a href="http://www.varnish-cache.org/">Varnish</a>
#    </address>
#  </body>
#</html>
#"};
#    return (deliver);
#}

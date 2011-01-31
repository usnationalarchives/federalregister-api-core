backend rails {
  .host = "fr2-rails.local";
  .port = "80";
}

backend blog {
  .host = "fr2.local";
  .port = "80";
}

sub vcl_fetch {
  if (req.url ~ "^(/blog|/policy|/learn|/layout/footer_page_list|/layout/homepage_post_list)") {
   set beresp.ttl = 120s;
  }
}

sub vcl_recv {
    # Reject Non-RFC2616 or CONNECT or TRACE requests.
    if (req.request != "GET" &&
      req.request != "HEAD" &&
      req.request != "PUT" &&
      req.request != "POST" &&
      req.request != "OPTIONS" &&
      req.request != "DELETE") {
        return (pipe);
    }
    
    # Compression handled upstream; only want one in the cache
    if (req.http.Accept-Encoding) {
        remove req.http.Accept-Encoding;
    }
    
    # Add a unique header containing the client address
    remove req.http.X-Forwarded-For;
    set    req.http.X-Forwarded-For = client.ip;
    
    # Pass POSTs etc directly on to the backend
    if (req.request != "GET" && req.request != "HEAD") {
        return (pass);
    }
    
    # Pass rails admin requests directly on to rails
    if (req.url ~ "^/admin" ){
        set req.http.host = "fr2-rails.local";
        set req.backend = rails;
        return (pass);
    }
    
    # Rewrite top-level wordpress requests to /blog/
    set req.url = regsub(
        req.url,
        "^/(learn|policy|layout/footer_page_list|layout/homepage_post_list)",
        "/blog/\1"
    );
    
    # Pass wp admin requests directly on to wp
    if (req.url ~ "^(/wp-login|wp-admin)") {
        set req.http.host = "fr2.local";
        set req.backend = blog;
        return (pass);
    }
    
    # Route to the correct backend
    if (req.url ~ "^(/blog|/policy|/learn|/layout/footer_page_list|/layout/homepage_post_list)") {
        set req.http.host = "fr2.local";
        set req.backend = blog;
        
        # Don't cache wordpress pages if logged in to wp
        if (req.http.Cookie ~ "wordpress_logged_in_") {
            return (pass);
        }
    } else {
      set req.http.host = "fr2-rails.local";
      set req.backend = rails;
    }
    
    # either return lookup for caching or return pass for no caching
    return (pass);
    # return (lookup);
}

sub vcl_fetch {
    unset beresp.http.Cache-Control;
    unset beresp.http.Etag;
    
    # Directly serve static content
    if (req.url ~ "^/images" || req.url ~ "^/javascripts" || req.url ~ "^/flash" || req.url ~ "^/stylesheets" || req.url ~ "^/sitemaps") {
        return(deliver);
    }
    # ESI process the rest
    else {
        esi;
    }
}

# vcl_hash creates the key for varnish under which the object is stored. It is
# possible to store the same url under 2 different keys, by making vcl_hash
# create a different hash.
sub vcl_hash {

    # these 2 entries are the default ones used for vcl. Below we add our own.
    set req.hash += req.url;
    set req.hash += req.http.host;
    
    # Hash differently based on presence of javascript_enabled cookie.
    if( req.url ~ "^/articles/search/header" && req.http.Cookie ~ "javascript_enabled=1" ) {
        # add this fact to the hash
        set req.hash += "javascript enabled";
    }
    
    return(hash);
}
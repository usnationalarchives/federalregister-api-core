backend default {
  .host = "fr2.local";
  .port = "80";
}

sub vcl_recv {
    /* Reject Non-RFC2616 or CONNECT or TRACE requests. */
    if (req.request != "GET" &&
      req.request != "HEAD" &&
      req.request != "PUT" &&
      req.request != "POST" &&
      req.request != "OPTIONS" &&
      req.request != "DELETE") {
        return (pipe);
    }
    
    /* Add a unique header containing the client address */
    remove req.http.X-Forwarded-For;
    set    req.http.X-Forwarded-For = client.ip;
    
    /* Pass POSTs etc directly on to the backend */
    if (req.request != "GET" && req.request != "HEAD") {
        return (pass);
    }
    
    /* Pass admin requests directly on to the backend */
    if (req.url ~ "^/admin/") {
        return (pass);
    }
    
    /* Check to see if cached */
    return (lookup);
}

sub vcl_fetch {
    /* Directly serve static content */
    if (req.url ~ "^/images" || req.url ~ "^/javascripts" || req.url ~ "^/flash" || req.url ~ "^/stylesheets" || req.url ~ "^/sitemaps") {
        return(deliver);
    }
    /* ESI process the rest */
    else {
        esi;
    }
}

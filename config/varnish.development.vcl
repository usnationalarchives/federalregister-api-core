backend default {
  .host = "fr2.local";
  .port = "80";
}

sub vcl_fetch {
    if (req.url ~ "^/images" || req.url ~ "^/javascripts" || req.url ~ "^/flash") {
        return(deliver);
    }
    else {
        /* Do ESI processing */
        esi;
    }
}

sub vcl_recv {
    # Add a unique header containing the client address
    remove req.http.X-Forwarded-For;
    set    req.http.X-Forwarded-For = client.ip;
}

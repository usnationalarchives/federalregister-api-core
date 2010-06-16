backend default {
  .host = "fr2.local";
  .port = "80";
}

sub vcl_fetch {
    if (req.url ~ "^/articles/search") {
        /* Do ESI processing */
        esi;
    }
    else {
        return(deliver);
    }
}

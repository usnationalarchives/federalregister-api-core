backend default {
  .host = "fr2.local";
  .port = "80";
}

sub vcl_fetch {
    if (req.url ~ "^/articles") {
        /* Do ESI processing */
        esi;
    }
    else {
        return(deliver);
    }
}

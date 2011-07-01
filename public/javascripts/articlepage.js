var citation_info = {
    cache: {},
    open: null,
    setup: function () {
        var anchor = "<span class='trigger'>Show citation box</span>";
        $(".body_column > *[id^='p-'], .body_column > ul > li[id^='p-']").append(anchor).addClass("citable");
        var self = this;
        $("#content_area").bind('click',
        function (event) {
            if ($(event.target).hasClass("trigger") && !$("body").hasClass("print_view")) {
                event.preventDefault();
                self.show($(event.target).parent().attr("id"));
            }
            if ($(event.target).hasClass("citable") && !$("body").hasClass("print_view")) {
                event.preventDefault();
                self.show($(event.target).attr("id"));
            }
        });
        $(".close").live("click",
        function (event) {
            event.preventDefault();
            self.hide($(this).parent().data("id"));
        });
    },
    create: function (index) {
        var id = "citation_info_" + index;
        var index_el = $("#" + index);
        var next_header = index_el.nextAll(':header').add(index_el.parentsUntil('#content_area').nextAll().find(':header')).first();
        var html = tmpl(this.template, {
            page: index_el.attr('data-page'),
            document_number: $(".doc_number").text(),
            url: 'http://' + window.location.host + '/a/' + $(".doc_number").text() + '/' + index,
            id: id,
            volume: $(".metadata_list .volume").text(),
            title: document.title,
            content: index_el.text(),
            next_header_text: next_header.text().replace(/ Back to Top/, ''),
            next_header_anchor: next_header.attr('id')
        });
        $("#sidebar").append(html);
        var id_el = $("#" + id);
        id_el.css({
            "top": index_el.position().top + 6,
            "right": 0
        }).data("id", index);
        this.cache[index] = id_el;
        return id;
    },
    show: function (id) {
        var node = $('#' + id);
        node.attr('id', '');
        window.location.hash = id;
        node.attr('id', id);

        if (this.cache[id] == null) {
            this.create(id);
        }
        if (this.open !== null && this.open !== id) {
            this.hide(this.open);
        }
        this.cache[id].fadeIn();
        $("#" + id).addClass("on");
        this.open = id;
    },
    hide: function (id) {
        this.cache[id].fadeOut();
        $("#" + id).removeClass("on");
    },
    template: [
      '<div id="<%= id %>" class="aside_box citation_box">',
      '  <ul>',
      '    <li class="link">',
      '      <a href="<%= url %>" target="_blank">Link to this paragraph</a>',
      '    </li>',
      '    <li class="cite_volume"><strong>Paragraph Citation</strong> <%= volume %> FR <%= page %></li>',
      '    <li class="cite_page"><strong>Page</strong> <%= page %></li>',
      '    <li class="twitter"><a href="http://twitter.com/home?status=<%= escape(url) %>" target="_blank">Share this on Twitter</a></li>',
      '    <li class="facebook"><a href="http://www.facebook.com/sharer.php?u=<%= escape(url) %>&t=<%= escape(title) %>" target="_blank">Share this on Facebook</a></li>',
      '    <li class="digg"><a href="http://digg.com/submit?url=<%= escape(url) %>&title=<%= escape(title) %>&bodytext=<%= escape(content) %>&media=news" target="_blank">Share this on digg</a></li>',
      '  </ul>',
      '  <div class="header_navigation_separator">',
      '    <ul>',
      '      <li class="top"><a href="#table_of_contents">Back to top</a></li>',
      '      <% if (next_header_anchor) { %>',
      '        <li class="next"><a href="#<%= next_header_anchor %>"><%= next_header_text %></a></li>',
      '      <% } %>',
      '   </ul>',
      '  </div>',
      '  <a href="#" class="close" title="Close this citation">Close</a>',
      '</div>'
    ].join("\n")
};

$(document).ready(function () {
    $('div.article[data-internal-id]').each(function () {
        var id = $(this).attr('data-internal-id');
        $.ajax({
            url: '/articles/views',
            type: 'POST',
            data: {
                'id': id,
                'referer': document.referrer
            }
        });
    });

    citation_info.setup();

    var font_size = 1;

    $(".increase").bind('click',
    function (event) {
        event.preventDefault();
        font_size += 0.1;
        $("#content_area").css("font-size", font_size + "em");
    });

    $(".decrease").bind('click',
    function (event) {
        event.preventDefault();
        font_size -= 0.1;
        $("#content_area").css("font-size", font_size + "em");
    });

    $(".reset").bind('click',
    function (event) {
        event.preventDefault();
        font_size = 1;
        $("#content_area").css("font-size", font_size + "em");
    });

    $(".serif").bind('click',
    function (event) {
        event.preventDefault();
        $(this).addClass("on");
        $(".sans").removeClass("on");
        $("#content_area").removeClass("sans");
    });

    $(".sans").bind('click',
    function (event) {
        event.preventDefault();
        $(this).addClass("on");
        $(".serif").removeClass("on");
        $("#content_area").addClass("sans");
    });

   function PrintViewManager() {
      var screen_sheets = $("head link[media=screen]");
      var print_sheets = $("head link[media=print]");
      this.enter = function(){
        screen_sheets.attr("media", "none");
        print_sheets.attr("media", "all");
        $("body").addClass("print_view");
      };
      this.exit = function(){
        if( $("body").hasClass("print_view") ){
          screen_sheets.attr("media", "screen");
          print_sheets.attr("media", "print");
          $("body").removeClass("print_view");
        }
      };
    }
    var print_view_manager = new PrintViewManager();
    
    if( $("#entries").length > 0 ){
      $(window).bind('hashchange', function(){
        location.hash === "#print_view" ? print_view_manager.enter() : print_view_manager.exit();
      }).trigger('hashchange');
    }
   
    if ( $("#select-cfr-citation-template").length > 0 ) {
      var citation_modal_template = Handlebars.compile($("#select-cfr-citation-template").html());
    }
    
    function display_cfr_modal(title, html) {
      if ($('#cfr_citation_modal').size() == 0) {
          $('body').append('<div id="cfr_citation_modal"/>');
      }
      $('#cfr_citation_modal').html(
        [
        '<a href="#" class="jqmClose">Close</a>',
        '<h3 class="title_bar">' + title + '</h3>',
        html
        ].join("\n")
      );
      $('#cfr_citation_modal').jqm({
          modal: true
      });
      $('#cfr_citation_modal').centerScreen().jqmShow();
    }


    // cfr citation modal
    $('a.cfr.external').bind('click', function(event) {
      var link = $(this);
      var cfr_url = link.attr('href');
      
      if( cfr_url.match(/^\//) ) {
        event.preventDefault();

        $.ajax({
          url: cfr_url,
          dataType: 'json',
          success: function(response) {
            cfr_html = citation_modal_template(response);
            display_cfr_modal('External CFR Selection', cfr_html);
          }
        });
      }
    });
});

var citation_info = {
  cache: {},
  open: null,
  setup: function(  ){
    var anchor = "<span class='trigger'>Show citation box</span>"
    $(".body_column > *[id^='p-'], .body_column > ul > li[id^='p-']").append(anchor).addClass("citable");
    var self = this;
    $("#content_area").bind('click', function(event) {
      if( $(event.target).hasClass("trigger") ){
        event.preventDefault();
        self.show( $(event.target).parent().attr("id") );    
      }
      if( $(event.target).hasClass("citable") ){
        event.preventDefault();
        self.show( $(event.target).attr("id") );    
      }
    });
    $(".close").live("click", function(event) {
      event.preventDefault();
      //self.cache[ $(this).parent().data("id") ].hide();
      self.hide( $(this).parent().data("id") );
    });
  },
  create: function( index ){
    var id = "citation_info_" + index;
    var index_el = $("#" + index);
    var next_header = index_el.nextAll('h1,h2,h3,h4,h5,h6').add(index_el.parentsUntil('#content_area').nextAll().find('h1,h2,h3,h4,h5,h6')).first();
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
    id_el.css({"top": index_el.position().top + 6, "right": 0}).data("id", index);
    this.cache[ index ] = id_el;
    return id;
  },
  show: function( id ){
    var node = $( '#' + id );
    node.attr( 'id', '' );
    window.location.hash = id;
    node.attr( 'id', id );
    
    if ( this.cache[id] == null )
      this.create( id );
    if ( this.open != null && this.open != id ){
      this.hide( this.open );
      }
    this.cache[id].fadeIn();
    $("#" + id).addClass("on");
    this.open = id;
  },
  hide: function( id ){
    this.cache[id].fadeOut();
    $("#" + id).removeClass("on")
  },
  template: [
    '<div id="<%= id %>" class="aside_box citation_box">',
    '  <ul>',
    '    <li class="link">',
    '      <a href="<%= url %>">Link to this paragraph</a>',
    '    </li>',
    '    <li class="cite_volume"><strong>Paragraph Citation</strong> <%= volume %> FR <%= page %></li>',
    '    <li class="cite_page"><strong>Page</strong> <%= page %></li>',
    // '    <li class="email"><a href="#">Email this</a></li>',
    '    <li class="twitter"><a href="http://twitter.com/home?status=<%= escape(url) %>">Share this on Twitter</a></li>',
    '    <li class="facebook"><a href="http://www.facebook.com/sharer.php?u=<%= escape(url) %>&t=<%= escape(title) %>">Share this on Facebook</a></li>',
    '    <li class="digg"><a href="http://digg.com/submit?url=<%= escape(url) %>&title=<%= escape(title) %>&bodytext=<%= escape(content) %>&media=news">Share this on digg</a></li>',
    '  </ul>',
    '  <div class="header_navigation_separator">',
    '    <ul>',
    // HELP-DESIGN: needs style for the back to top icon
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

$(document).ready(function() {
  //   if( $("#entries.show").size() > 0 ){
  //     $("ul.table_of_graphics").before('<div id="gallery"><div id="controls"></div><div class="slideshow-container"><div id="loading"></div><div id="slideshow"></div><div id="caption"></div></div></div>');
  //     $("ul.table_of_graphics").wrap("<div id='thumbs'></div>");
  //    $('div.navigation').css({'width' : '200px', 'float' : 'left'});
  //      var gallery = $('#thumbs').galleriffic({  
  //        imageContainerSel:      '#slideshow',
  //       controlsContainerSel:   '#controls'
  //      });
  // }
  //   
  $('div.article[data-internal-id]').each(function(){
    var id = $(this).attr('data-internal-id');
    $.ajax({
      url: '/articles/views',
      type: 'POST',
      data: {'id': id}
    });
  });
  
  citation_info.setup();
  
  $(document).ready(function() {
    $('#disclaimer a').click(function(){
      generate_dialog();
      $('#modal').centerScreen().jqmShow(); 
      return false;
  });

    function generate_dialog(){
      if ($('#modal').size() == 0) {
        var html = [
          '<div id="modal">',
          '  <a href="#" class="jqmClose">Close</a>',
          '  <h3>Legal Status Disclaimer</h3>',
          '  <p>The content posted on this site, taken from the daily Federal Register (FR), is not an official, legal edition of the FR; it does not replace the official print or electronic versions of the FR. Each document posted on the site includes a link to the corresponding official FR PDF file.  For more information, see our <a href="/legal_status">Legal Status</a> page.</p>',
          '</div>'
        ].join("\n")

        $('body').append(html);
        $('#modal').jqm({modal: true, toTop: true});
      }
    }
  });
});




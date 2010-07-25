$(document).ready(function () {
    $("input[placeholder]").textPlaceholder();
    $("body").find(":first-child").addClass("firstchild");
    $("body").find(":last-child").addClass("lastchild");
    $("a[href^='http://www.flickr.com']").bind('click', function (event) {
      var timer;
      event.preventDefault();
      generate_exit_dialog();
      $("#exit_modal .flickr_link").attr("href", $(this).attr("href")).text( $(this).attr("href") );
      jqmHandlers.setHref( $(this).attr("href") );
      $("#exit_modal").centerScreen().jqmShow();
    }); 
});

var jqmHandlers = {
  href: "",
  timer: "",
  show: function ( hash ){
    hash.w.show();
    timer = setTimeout(function() {
      window.location = href;
    }, 10000);
  },
  hide: function ( hash ){
    hash.w.hide();
    hash.o.remove();
    clearTimeout(timer);
  },
  setHref: function ( link ){
    href = link;
  }
}

function generate_exit_dialog() {
  if( $("#exit_modal").size() == 0 ) {
      
    var template =[
    '<div id="exit_modal">',
    '  <a href="#" class="jqmClose close">Close</a>',
    '  <h3 class="title_bar">Notice</h3>',
    '  <h4>You are now leaving the FederalRegister.gov website.</h4>',
    '  <p>Click the link below to continue or wait 10 seconds to be transferred to:</p>',
    '  <a href="http://www.flickr.com/" class="external_link flickr_link">http://www.flickr.com/</a>',
    '  <p>You are linking to a photograph that is sourced from Flickr under a Creative Commons license. All photographs on FederalRegister.gov news section pages are published with attribution to the photo owner, and are consistent with the terms of use specified by the photo owner. For more information on <a href="http://www.flickr.com/" title="Welcome to Flickr - Photo Sharing">Flickr</a> and <a href="http://creativecommons.org/" title="">Creative Commons</a> licensing see: <a href="http://www.flickr.com/creativecommons/" title="Flickr: Creative Commons">http://www.flickr.com/creativecommons/</a>. The photographs on news section pages are generic illustrations of subject matter; they are not abstracted from the text of Federal Register documents. FederalRegister.gov assumes no responsibility for public comments on photographs that may appear on the Flickr website.</p>',
    '  <p>We have provided a link to this site because it has information that may interest you. This link is not an endorsement by the National Archives’s Office of the Federal Register or the Government Printing Office of the opinions, products, or services presented on this site, or any sites linked to it. We are not responsible for the legality or accuracy of information on this site, the policies, or for any costs incurred while using this site.</p>',
    '  <p>Thank you for visiting the Federal Register online!</p>',
    '</div>'].join("\n");
    
    $('body').append(tmpl(template));
    
    $('#exit_modal').jqm({
        modal: true,
        toTop: true,
        onShow: jqmHandlers.show,
        onHide: jqmHandlers.hide
    });
  }
}


function unimplemented() {
    alert("This feature is not implemented yet.");
}

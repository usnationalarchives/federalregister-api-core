function closeOnEscape(hash) {
  $(window).one('keyup', function(event) {
    if( event.keyCode === '27' ){
      hash.w.jqmHide();
    }
  });
}
/*global modalOpen:true */
var modalOpen = function(hash) {
  closeOnEscape(hash);
  hash.w.show();
};

var jqmHandlers = {
    href: "",
    timer: "",
    show: function (hash) {
        hash.w.show();
        this.timer = setTimeout(function () {
            window.location = $('#exit_modal').attr('data-href');
        },
        10000);
        closeOnEscape(hash);
    },
    hide: function (hash) {
        hash.w.hide();
        hash.o.remove();
        clearTimeout(this.timer);
    },
    setHref: function (link) {
        $('#exit_modal').attr('data-href', link);
    }
};

function generate_exit_dialog() {
    if ($("#exit_modal").size() === 0) {

        var template = [
        '<div id="exit_modal">',
        '  <a href="#" class="jqmClose">Close</a>',
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

function generate_print_disclaimer(){
  var template = [
  '<p>This site displays a prototype of a “Web 2.0” version of the daily Federal Register. It is not an official legal edition of the Federal Register, and does not replace the official print version or the official electronic version on GPO’s Federal Digital System (FDsys.gov).</p>',
  '<p>The documents posted on this site are XML renditions of published Federal Register documents. Each document posted on the site includes a link to the corresponding official PDF file on FDsys.gov. This prototype edition of the daily Federal Register on FederalRegister.gov will remain an unofficial informational resource until the Administrative Committee of the Federal Register (ACFR) issues a regulation granting it official legal status.   For complete information about, and access to, our official publications and services, go to the <a href="http://www.ofr.gov/" title="Office of the Federal Register">OFR.gov website</a>. </p>',
  '<p>The OFR/GPO partnership is committed to presenting accurate and reliable regulatory information on FederalRegister.gov with the objective of establishing the XML-based Federal Register as an ACFR-sanctioned publication in the future. While every effort has been made to ensure that the material on FederalRegister.gov is accurately displayed, consistent with the official SGML-based PDF version on FDsys.gov, those relying on it for legal research should verify their results against an official edition of the Federal Register.  Until the ACFR grants it official status, the XML rendition of the daily Federal Register on FederalRegister.gov does not provide legal notice to the public or judicial notice to the courts.</p>'
  ].join("\n");
  
   $('#print-disclaimer').append(tmpl(template));
} 

function unimplemented() {
    alert("This feature is not implemented yet.");
}

// http://www.quirksmode.org/js/cookies.html
function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0) ===' ') {c = c.substring(1,c.length);}
    if (c.indexOf(nameEQ) === 0) {return c.substring(nameEQ.length,c.length);}
  }
  return null;
}

$(document).ready(function () {
    // let the server know the user has JS enabled
    document.cookie = "javascript_enabled=1; path=/";
    
    $("input[placeholder]").textPlaceholder();
    
    if($.browser.msie && $.browser.version.substr(0,1) < 7) {
      $("li:first-child, ul:first-child, dt:first-child").addClass("firstchild");
      $("li:last-child, ul:last-child, dd:last-child").addClass("lastchild");
      $(".dropdown").hover(function(e){ $(this).addClass("hover"); }, function(e){ $(this).removeClass("hover"); });
    }
    
    generate_print_disclaimer();
    
    $(".jqmClose").live('click', function (event) {
      $(this).parent().jqmHide();
    });
    
    var requires_captcha_without_message = $("#email_pane").attr('data-requires-captcha-without-message') === 'true';
    var requires_captcha_with_message = $("#email_pane").attr('data-requires-captcha-with-message') === 'true';
    if( requires_captcha_without_message || requires_captcha_with_message) { 
      $("#entry_email_message").bind('blur', function(event) {
        if( requires_captcha_without_message || ( requires_captcha_with_message && $("#entry_email_message").val() !== '' )) {
          $("#recaptcha_widget_div").show();
        }
        else {
          $("#recaptcha_widget_div").hide();
        }
      });
      $("#entry_email_message").blur();

      $("#entry_email_message").bind('focus', function(event) {
        if( requires_captcha_with_message ) {
          $("#recaptcha_widget_div").show();
        }
      });
    }

    
    $("a[href^='http://www.flickr.com']").bind('click',
    function (event) {
        var timer;
        event.preventDefault();
        generate_exit_dialog();
        $("#exit_modal .flickr_link").attr("href", $(this).attr("href")).text($(this).attr("href"));
        jqmHandlers.setHref($(this).attr("href"));
        $("#exit_modal").centerScreen().jqmShow();
    });

    if( $(".collapse").length > 0 ) {
      $(".collapse").collapse();
    }
});


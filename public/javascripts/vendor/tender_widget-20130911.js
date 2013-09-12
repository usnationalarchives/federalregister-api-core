(function(){
  
  var getHost = function(){
    var scripts = document.getElementsByTagName("script");
    for(var i=0; i<scripts.length; i++){
      var script = scripts[i].src;
      if(script.match(/tender_widget\.js(\?.*)?$/)){
        var host = "https://federalregister.tenderapp.com/";  //script.substring(0, script.indexOf("tender_widget.js"));
      }
    }
    return host;
  };
 
  var articlePageRegEx = new RegExp('\/articles\/\\d{4}');
  var articlePage = function() {
    return articlePageRegEx.test(window.location.href);
  };

  var showInterstitialModal = function () {
    var interstitial_tender_modal_template = $('#interstitial-tender-modal-template');
    if ( interstitial_tender_modal_template.length > 0 ) {
      interstitial_tender_modal_template = Handlebars.compile( interstitial_tender_modal_template.html() );

      var document_feedback_text, 
          document_button_enabled = '',
          formal_comment_link = $('.button.formal_comment');

      if( formal_comment_link.length > 0 && formal_comment_link.first().attr('href') != '#addresses') {
        document_feedback_text = "If you would like to submit a formal comment to the issuing agency on the document you are currently viewing, please use the 'Document Feedback' button below.";
      } else if( $('#addresses').length > 0 || $('#furinf').length > 0 ) {
        document_feedback_text = "If you would like to comment on the current document, please use the 'Document Comment' button below for instructions on contacting the issuing agency";
      } else {
        document_feedback_text = "The current document is not open for formal comment, please use other means to contact " + $('.metadata .agencies').html() + " directly.";
        document_button_enabled = 'disabled';
      }


      display_modal('', 
                    interstitial_tender_modal_template({document_feedback_text: document_feedback_text,
                                                        document_button_enabled: document_button_enabled}),
                    {modal_id: '#interstitial_tender_modal', 
                     include_title: false, 
                     modal_class: 'fr_modal wide'});

      $('#interstitial_tender_modal').on('click', '.site_feedback .button', function(event) {
        event.preventDefault();
        $('#interstitial_tender_modal').remove();

        show();
      });

      $('#interstitial_tender_modal').on('click', '.document_feedback .button:not(.disabled)', function(event) {
        event.preventDefault();
        $('#interstitial_tender_modal').jqmHide();

        var formal_comment_link = $('.button.formal_comment');

        if( formal_comment_link.length > 0 && formal_comment_link.first().attr('href') != '#addresses') {
          /* open in new window */
          window.open(
            formal_comment_link.attr('href'),
            '_blank'
          );
        } else if( $('#addresses').length > 0 ) {
          window.location.href = '#addresses';
        } else {
          window.location.href = '#furinf';
        }
      });
    } else {
      /* fallback to showing the tender modal */
      show();
    }
  }

  var visible = false;
  var initialized = false;
  var host = getHost();
  if (!host || host === "") host = "https://help.tenderapp.com/";
  
  var showWidget = function(){
    if( articlePage() ) {
      showInterstitialModal();
    } else {
      show();
    }
  };
  
  var show = function(){
    if (!initialized) {
      initialize();
    } else {
      document.getElementById('tender_window').style.display = '';
      visible = true;
    }
  };
  
  var hide = function(){
    document.getElementById('tender_window').style.display = 'none';
    if (typeof(Tender) === "undefined" || !Tender.hideToggle) document.getElementById('tender_toggler').style.display = '';
    visible = false;
  };

  var initialize = function(){
    var element = document.createElement('div');
    var url     = host + 'widget/discussion/new?r=' + Math.random() + '&discussion[body]=' + encodeURIComponent( "\n\n\n\n\n-----------------\n" + "URL: " + window.location + "\n" + "BROWSER: " + navigator.userAgent) ;
    if (typeof(Tender) !== "undefined" && Tender.sso)
      url += "&sso=" + encodeURIComponent(Tender.sso)
    if(typeof Tender !== 'undefined' && Tender.widgetEmail)
      url += '&email=' + encodeURIComponent(Tender.widgetEmail)
      
    var wrapper = '<div id="tender_window"><a href="#" id="tender_closer">Close</a><div id="tender_frame"><iframe src="' + url + '" scrolling="no" frameborder="0" width="100%" height="100%"></iframe></div></div>';
    element.innerHTML = wrapper;
    var iframe = element.getElementsByTagName('iframe')[0];
    document.body.appendChild(element);
    var close_link = document.getElementById('tender_closer');
    close_link.onclick = function(){
      $('.jqmOverlay').remove();
      hide();
      return false;
    };

    initialized = true;
    show();
  };
  
  if (typeof(Tender) != "undefined" && Tender.widgetToggles){
    for(var i=0; i<Tender.widgetToggles.length; i++){
      var toggle = Tender.widgetToggles[i];
      if (toggle == null) continue;
      toggle.onclick = function(event){
        showWidget();
        return false;
      };
    }
  }
  
  var styles = "#tender_window{ position:absolute; top:20px; left:50%; margin-left:-340px; width:680px; height:615px; padding:3px; background:url(" + host + "images/widget/overlay_back.png); z-index:9999; }";
  styles +=    "#tender_window iframe{ border:none; width:100%; height:100%; } ";
  styles +=    "#tender_window #tender_frame{ width:100%; height:100%; background:url(" + host + "images/widget/loader.gif) 50% 50% no-repeat #fff; } ";
  styles +=    "#tender_closer{ position:absolute; top:18px; right:18px; color:#fff; font-family:Helvetica, Arial, sans-serif; font-size:12px; font-weight:bold; text-decoration:none; border:none; } ";
  styles +=    "#tender_toggler{ position:absolute; top:100px; right:0px; width:33px; height:105px; padding:3px 0 3px 3px; background:url(" + host + "images/widget/overlay_back.png); } ";
  styles +=    "#tender_toggler_link{ display:block; width:100%; height:100%; text-decoration:none; border:none; background:#006699; text-indent:-9999px; background:url(" + host + "images/widget/tab_text.gif); } ";
  
  var style = document.createElement('style');
  style.setAttribute("type", "text/css");
  style.setAttribute("charset", "utf-8");
  try{ // For safari's sake
    style.appendChild(document.createTextNode(styles));
    document.getElementsByTagName("head").item(0).appendChild(style);
  }catch(e){ }
  
  // For IE
  if(document.createStyleSheet) {
    document.createStyleSheet(host + 'tender_widget_styles.css');
  }

})();

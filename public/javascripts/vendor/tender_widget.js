(function(){
  
  var getHost = function(){
    var scripts = document.getElementsByTagName("script");
    for(var i=0; i<scripts.length; i++){
      var script = scripts[i].src;
      if(script.match(/tender_widget\.js(\?.*)?$/)){
        var host = "http://federalregister.tenderapp.com/";  //script.substring(0, script.indexOf("tender_widget.js"));
      }
    }
    return host;
  }
  
  var visible = false;
  var initialized = false;
  var host = getHost();
  if (!host || host == "") host = "http://help.tenderapp.com/";
  
  var showWidget = function(){
    if (!initialized) initialize();
    else show();
  }
  
  var show = function(){
    document.getElementById('tender_window').style.display = '';
    visible = true;        
  }
  
  var hide = function(){
    document.getElementById('tender_window').style.display = 'none';
    if (typeof(Tender) == "undefined" || !Tender.hideToggle) document.getElementById('tender_toggler').style.display = '';
    visible = false;
  }

  var initialize = function(){
    var element = document.createElement('div');
    var url     = host + 'widget/discussion/new?r=' + Math.random() + '&discussion[body]=' + encodeURIComponent( "\n\n\n\n\n-----------------\n" + "URL: " + window.location + "\n" + "BROWSER: " + navigator.userAgent) ;
    if (typeof(Tender) != "undefined" && Tender.sso)
      url += "&sso=" + encodeURIComponent(Tender.sso)
    if(typeof Tender != 'undefined' && Tender.widgetEmail)
      url += '&email=' + encodeURIComponent(Tender.widgetEmail)
      
    var wrapper = '<div id="tender_window"><a href="#" id="tender_closer">Close</a><div id="tender_frame"><iframe src="' + url + '" scrolling="no" frameborder="0" width="100%" height="100%"></iframe></div></div>';
    element.innerHTML = wrapper;
    var iframe = element.getElementsByTagName('iframe')[0];
    document.body.appendChild(element);
    var close_link = document.getElementById('tender_closer');
    close_link.onclick = function(){
      hide();
      return false;
    } 

    initialized = true;    
    show();
  }
  
  if (typeof(Tender) != "undefined" && Tender.widgetToggles){
    for(var i=0; i<Tender.widgetToggles.length; i++){
      var toggle = Tender.widgetToggles[i];
      if (toggle == null) continue;
      toggle.onclick = function(){
        showWidget();
        return false;
      }
    }
  }
  
  var styles = "#tender_window{ position:absolute; top:20px; left:50%; margin-left:-340px; width:680px; height:615px; padding:3px; background:url(" + host + "images/widget/overlay_back.png); z-index:9999; }";
  styles +=    "#tender_window iframe{ border:none; width:100%; height:100%; } ";
  styles +=    "#tender_window #tender_frame{ width:100%; height:100%; background:url(" + host + "images/widget/loader.gif) 50% 50% no-repeat #fff; } ";
  styles +=    "#tender_closer{ position:absolute; top:18px; right:18px; color:#fff; font-family:Helvetica, Arial, sans-serif; font-size:12px; font-weight:bold; text-decoration:none; border:none; } ";
  styles +=    "#tender_toggler{ position:absolute; top:100px; right:0px; width:33px; height:105px; padding:3px 0 3px 3px; background:url(" + host + "images/widget/overlay_back.png); } ";
  styles +=    "#tender_toggler_link{ display:block; width:100%; height:100%; text-decoration:none; border:none; background:#006699; text-indent:-9999px; background:url(" + host + "images/widget/tab_text.gif); } "
  
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

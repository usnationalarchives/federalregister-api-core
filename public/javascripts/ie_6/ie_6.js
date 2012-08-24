function display_deprecation_modal(title, html) {
      if ($('#deprecation_modal').size() === 0) {
          $('body').append('<div id="deprecation_modal">');
      }
      $('#deprecation_modal').html(
        [
        '<a href="#" class="jqmClose">Close</a>',
        '<h3 class="title_bar">' + title + '</h3>',
        html
        ].join("\n")
      );
      $('#deprecation_modal').jqm({
          modal: true,
          toTop: true,
          onShow: this.modalOpen
      });
      $('#deprecation_modal').centerScreen().jqmShow().css('position', 'absolute');
  }

$(document).ready(function(){
  display_deprecation_modal('Insecure Browser Warning', 
                            '<p>The browser you are using is insecure. The web has changed significantly over the past 10 years and the latest versions of browsers will enhance your experience and help protect you from new attacks and threats. Learn more from <a href="http://www.ie6countdown.com/educate-others.aspx">Microsoft here</a>.</p><p>Unfortunately we cannot guarantee the functionality of FederalRegister.gov in your browser. However there many great free options available to you. You can upgrade your browser to the latest version of <a href="http://windows.microsoft.com/en-US/internet-explorer/downloads/ie">Microsoft\'s Internet Explorer</a>, or try out the excellent <a href="http://www.google.com/chrome">Google Chrome</a>, <a href="http://www.apple.com/safari/">Apple Safari</a> or <a href="http://www.mozilla.org/firefox">Mozilla Firefox</a> browsers.</p>');
});

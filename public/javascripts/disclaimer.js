$(document).ready(function() {
  
  $('#disclaimer a').bind('click',
  function (event) {
      event.preventDefault();
      display_modal('Legal Status Disclaimer', '<p>The content posted on this site, taken from the daily Federal Register (FR), is not an official, legal edition of the FR; it does not replace the official print or electronic versions of the FR. Each document posted on the site includes a link to the corresponding official FR PDF file.  For more information, see our <a href="/policy/legal_status">Legal Status</a> page.</p>');
  });

  function display_modal(title, html) {
      if ($('#disclaimer_modal').size() == 0) {
          $('body').append('<div id="disclaimer_modal"/>');
      }
      $('#disclaimer_modal').html(
        [
        '<a href="#" class="jqmClose">Close</a>',
        '<h3 class="title_bar">' + title + '</h3>',
        html
        ].join("\n")
      );
      $('#disclaimer_modal').jqm({
          modal: true,
          toTop: true
      });
      $('#disclaimer_modal').centerScreen().jqmShow();
  }
  
});

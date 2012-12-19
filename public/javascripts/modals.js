/* some modals still live in disclaimer.js */
$(document).ready(function() {
  var developer_article_formats_modal_template;
  if ( $("#developer-article-formats-modal-template").length > 0 ) {
    developer_article_formats_modal_template = Handlebars.compile($("#developer-article-formats-modal-template").html());
  }

  $('#entries #trigger-dev-modal').bind('click',
  function (event) {
      event.preventDefault();
      display_modal('Developer Friendly Formats', developer_article_formats_modal_template(dev_formats) );
  });
});

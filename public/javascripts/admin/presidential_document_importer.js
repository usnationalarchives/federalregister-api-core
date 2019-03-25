$(document).ready(function() {

  var delayInterval = 5000;

  if ($('.eo-import-status').data('status') === 'continue-polling') {
    setInterval(function() {window.location.reload();}, delayInterval);
  }

});

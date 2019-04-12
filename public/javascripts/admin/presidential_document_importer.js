$(document).ready(function() {

  var delayInterval = 10000;

  if ($('.eo-import-status').data('status') === 'continue-polling') {
    setInterval(function() {window.location.reload();}, delayInterval);
  }

});

// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=2:shiftwidth=2:softtabstop=2:smarttab:shiftround:expandtab
$(document).ready(function() {
  $('body').on('click', '.alert-message a.close', function (ev) {
    $(ev.target).parents('.alert-message').fadeOut();
  });

  $.get('/templates.html').done(function (content) {
    $('body').append(content);
    window.router = new jsGA.AppRouter;
    Backbone.history.start({root: '/#'});
  });
});

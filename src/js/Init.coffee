# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=2:shiftwidth=2:softtabstop=2:smarttab:shiftround:expandtab
$(document).ready(() ->
  $('body').on('click', '.alert-message a.close', (ev) ->
    $(ev.target).parents('.alert-message').fadeOut()
  )

  $.get('/templates.html').done((content) ->
    $('body').append(content)
    window.router = new jsGA.AppRouter()
    Backbone.history.start({root: '/#'})
  )
)

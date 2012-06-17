# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}


jsGA.HelpView = Backbone.View.extend(
    className: 'help'

    initialize: (options) ->
        options or= {}
        _.bindAll(this)
        @template = _.template(options.template || $('#help-view-template').html())

    render: ->
        $('.navbar li').removeClass('active')
        $('.navbar a[href="#help"]').parents('li').addClass('active')
        $(@el).html(@template())
        if @options.topic
            # expand this.options.topic
            @$('#' + @options.topic).collapse('show')

        this
)

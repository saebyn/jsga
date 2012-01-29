# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}

jsGA.PopulationSettingsView = Backbone.View.extend(
    tagName: 'div'
    className: 'settings'

    initialize: (options) ->
        options = options || {}
        @template = _.template(options.template || $('#population-settings-view-template').html())
        @model.bind('change', @render, @)

    render: () ->
        $(@el).html(@template({settings: @model}))
        @
)

# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {};

jsGA.OrganismView = Backbone.View.extend(
    events:
        'click .close': 'close'

    className: 'organism'

    initialize: (options) ->
        options or= {}
        @template = _.template(options.template || $('#organism-template').html())

    render: ->
        if @model
            $(@el).attr('id', @model.cid)

            $(@el).html(@template({model: @model}))
            vis = new jsGA.ChromosomeVisualization(@$('.vis'), 250, 250)
            vis.addChromosome(@model.get('chromosome'), @model.get('bases'))
            vis.render()
        else
            $(@el).html('<div class="alert-message error">Does not exist.</div>')

        this

    close: =>
        @remove()
        window.router.navigate('', false)
)

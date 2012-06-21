# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}

jsGA.OrganismSimpleView = Backbone.View.extend(
    tagName: 'li'
    className: 'organism simple'
    events:
        'click': 'showDetails'

    initialize: (options) ->
        _.bindAll(this, 'showDetails')

    render: ->
        $(@el).text(JSON.stringify(@model.get('chromosome')))
        $(@el).attr('id', @model.cid)
        # TODO build Viz prototype in population view for each organism type,
        #      then give that prototype to the organism views and have them
        #      extend it.
        vis = new jsGA.ChromosomeVisualization(@el)
        vis.addChromosome(this.model.get('chromosome'), @model.get('bases'))
        vis.render()
        this

    showDetails: ->
        if @options.generationId
            window.router.navigate('past/' + @options.generationId + '/organism/' + @model.cid, true)
        else
            window.router.navigate('organism/' + @model.cid, true)
)

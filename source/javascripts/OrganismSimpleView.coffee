# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}

jsGA.OrganismSimpleView = Backbone.View.extend(
    tagName: 'li'
    className: 'organism simple'
    events:
        'click': 'showDetails'

    initialize: () ->
        _.bindAll(this, 'showDetails')

    render: () ->
        $(@el).text(JSON.stringify(@model.get('chromosome')))
        $(@el).attr('id', @model.cid)
        vis = new jsGA.ChromosomeVisualization(@el)
        vis.addChromosome(this.model.get('chromosome'), @model.get('bases'))
        vis.render()

        @

    showDetails: () ->
        window.router.navigate('organism/' + @model.cid, true)
)

# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}

jsGA.AppRouter = Backbone.Router.extend(
    routes:
        '': 'index'
        'create': 'createPopulation'
        'organism/:id': 'viewOrganism'
          
    initialize: (optioins) ->
        @population = new jsGA.Population()

    index: () ->
        if ( @population.length <= 0 )
            @navigate('create', true)
            return

        this.populationView = new jsGA.PopulationView(
            collection: @population
        )
        $('#main').html(@populationView.render().el)
        $('#side').html('')

    createPopulation: () ->
        @createPopulationView = new jsGA.CreatePopulationView(
            collection: @population
        )
        $('#main').html(@createPopulationView.render().el)
        $('#side').html('')

    viewOrganism: (id) ->
        @organismView = new jsGA.OrganismView(
            model: @population.getByCid(id)
        )
        $('#side').html(@organismView.render().el)
)

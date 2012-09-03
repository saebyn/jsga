# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}

# TODO add a view that shows our connection to the server that passes
# organisms between clients, show the graph of how population pools are
# connected and their distances, allow the user to connect to a server.
# TODO show link to that in the navbar, and show an icon indicating
# connection status
# TODO we'll need to distinguish between different organism types,
# since each client/pool that connects might have different settings
# for the generated organisms and we'll want to just treat them
# as different organism types. this has the side effect of making
# the different species all compete for space
#

jsGA.AppRouter = Backbone.Router.extend(
    routes:
        '': 'index'
        'create': 'createPopulation'
        'past': 'viewPopulationHistory'
        'statistics': 'viewStatistics'
        'organism/:id': 'viewOrganism'
        'past/:generationId/organism/:id': 'viewPastOrganism'
        'help/:topic': 'viewHelp'
        'help': 'viewHelp'
          
    initialize: (options) ->
        @population = new jsGA.Population()

    index: ->
        if not Modernizr.canvas or not Modernizr.localstorage
            $('#main').html('<div class="alert-message error">Your browser does not support the &lt;canvas&gt; element or the HTML5 Web Storage API. Please upgrade your browser to use this application.</div>')
            return

        if @population.length == 0
            @navigate('create', true)
            return

        # Disconnect generational log events from any previous views.
        @population.unbind 'genlog'
        @populationView = new jsGA.PopulationView(
            collection: @population
        )
        $('#main').html(@populationView.render().el)
        $('#side').html('')

    createPopulation: ->
        @createPopulationView = new jsGA.CreatePopulationView(
            collection: @population
        )
        $('#main').html(@createPopulationView.render().el)
        $('#side').html('')

    viewPopulationHistory: ->
        if not @population?.previousId?
            @navigate('create', true)
            return

        logView = new jsGA.GenerationLogView({population: @population})
        $('#main').html(logView.render().el)
        $('#side').html('')

    viewStatistics: ->
        statView = new jsGA.StatisticsView({population: @population})
        $('#main').html(statView.render().el)
        $('#side').html('')

    viewPastOrganism: (generationId, id) ->
        @organismView = new jsGA.OrganismView(
            model: jsGA.getOrganismFromLog(@population, generationId, id)
        )
        $('#side').html(@organismView.render().el)

    viewOrganism: (id) ->
        @organismView = new jsGA.OrganismView(
            model: @population.getByCid(id)
        )
        $('#side').html(@organismView.render().el)

    viewHelp: (topic) ->
        helpView = new jsGA.HelpView({topic: topic})
        $('#main').html(helpView.render().el)
        $('#side').html('')
)

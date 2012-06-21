# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}


jsGA.GenerationLogView = Backbone.View.extend(
    tagName: 'ol'
    className: 'generations'

    initialize: (options) ->
        @options = options || {}

    getGenerations: ->
        generations = []
        previousId = @options.population.previousId
        # Loop over all generations, starting with the one immediately
        # before the current population, until either no previous generation
        # exists or is no longer in the session storage.
        while previousId != null
            # grab the generation from session storage with previousId
            json = window.sessionStorage[previousId]
            # if generation lookup fails, break the loop
            if json is undefined
                break

            generation = JSON.parse(json)

            # Add bases from population settings into each organism
            # Restore previous cid
            population = _.map(generation.population, (attrs) ->
                attrs.bases = @options.population.getAvailableBasesForOrganism(attrs.type)
                organism = new jsGA.Organism(attrs)
                organism.cid = attrs.cid
                organism._fitness = attrs.fitness
                organism
            , this)

            # create a collection, push it into generations
            generations.push([previousId, new Backbone.Collection(population,
                comparator: (organism) ->
                    -organism.get('fitness')
            )])

            # find the id of the generation prior to the fetched one
            previousId = generation.parent

        generations

    renderGeneration: (generation) ->
        [id, population] = generation

        if population.length == 0
            return

        view = new jsGA.PopulationSimpleView(
            collection: population
            pageSize: 10
            generation: @generationCount
            generationId: id
        )
        @generationCount -= 1
        @$el.append(view.render().el)

    render: ->
        $('.navbar li').removeClass('active')
        $('.navbar a[href="#past"]').parents('li').addClass('active')
        @$el.html('')
        generations = @getGenerations()
        @generationCount = generations.length - 1
        _.each(generations, @renderGeneration, this)
        this
)

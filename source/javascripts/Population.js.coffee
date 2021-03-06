# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}

jsGA.Population = Backbone.Collection.extend(
    initialize: (models, options) ->
        @options = options || {}

        # Every time the population is reset, give it a new id.
        @bind('reset', ->
            @previousId = @id
            @id = _.uniqueId('p')
            if not @firstId?
                @firstId = @id
        , this)

        @settings = new jsGA.PopulationSettings
        @updateSelector(@settings.get('selectionMechanism'))
        @model = @options.model || jsGA.Organism

    #
    # comparator
    #
    # Causes the collection to be sorted by fitness in descending order.
    #
    comparator: (organism) ->
        -organism.fitness()

    #
    # getAvailableBasesForOrganism
    #
    # Get an array of available chromosome bases for the organism type.
    #
    getAvailableBasesForOrganism: (type) ->
        @settings.get('bases')

    #
    # seed
    #
    # Add organisms to the population.
    #
    seed: (settings) ->
        # Keep the settings model around for later use.
        @settings.set(settings.toJSON())
        @updateSelector(settings.get('selectionMechanism'))

        # Define the default options for population seeding.
        defaultOptions = {size: 2}
        options = {}

        options = settings.toJSON()

        # Override the default options with any that were passed in.
        options = _.extend(defaultOptions, options)

        jsGA.generationLog(this, options for i in [0...options.size])

    #
    # run
    #
    # Select, crossover, and mutate for the specified number of
    # generations.
    #
    run: (generations) ->
        generations ?= 1

        if ( generations <= 0 )
            return

        @step()
        @trigger('generation', generations-1)
        @timer = setTimeout ( =>
            @run(generations-1)
        ), 100

    stop: () ->
        if @timer
            clearTimeout(@timer)
            @timer = false

    step: () ->
        newOrganisms = @topProportion(@settings.get('elitism') / 100.0)
        newOrganismsNeeded = @length - newOrganisms.length

        while ( newOrganismsNeeded > 0 )
            choices = @selector.choose(this)
            if ( choices == false )
                break

            # Perform the crossover operation.
            children = choices[0].crossover(choices[1])
            children[0].mutate()
            children[1].mutate()
            # Append the children to the array of new organisms.
            newOrganisms.push.apply(newOrganisms, children)
            # Now we need two less organisms that we did before.
            newOrganismsNeeded -= 2

        _.each(newOrganisms, (organism) ->
            organism.set({life: organism.get('life') + 1})
        )

        jsGA.generationLog(this, newOrganisms)

    totalFitness: () ->
        @reduce((memo, organism) ->
                memo + organism.fitness()
            , 0.0)

    updateSelector: (selectorName) ->
        if ( @options.selector )
            @selector = @options.selector
            return

        @selector = switch @settings.get('selectionMechanism')
            when 'fp' then new jsGA.FitnessProportionateSelector()
            when 'tournament' then new jsGA.TournamentSelector(@settings.get('tournamentSize'))

    topProportion: (proportion) ->
        total = Math.floor(@length * proportion)
        @first(total)
)

# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}

# Save the current generation, if present, to the log. Reset the collection
# with the next generation. Assumes that the existing population collection
# has an id.
jsGA.generationLog = (population, children) ->
    if population.id
        simplePop = population.map((model) ->
            cid: model.cid
            parents: model.get('parents')
            life: model.get('life')
            chromosome: model.get('chromosome')
            type: model.get('type')
            fitness: model.fitness()
        )
        generation = {population: simplePop, parent: population.previousId}
        # TODO if we start running out of space, do something about it
        window.sessionStorage[population.id] = JSON.stringify(generation)
        population.trigger('genlog')

    population.reset(children)


jsGA.getOrganismFromLog = (currentPopulation, generation, id) ->
    json = window.sessionStorage[generation]

    if json
        population = JSON.parse(json).population
        attrs = _.find(population, (o) -> o.cid == id)
        if attrs
            attrs.bases = currentPopulation.getAvailableBasesForOrganism(attrs.type)
            organism = new jsGA.Organism(attrs)
            organism._fitness = attrs.fitness
            organism.cid = id
            organism


jsGA.visitGenerations = (population, callback) ->
    previousId = population.previousId
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

        if generation and generation.population.length > 0
            callback(generation.population)

        # find the id of the generation prior to the fetched one
        previousId = generation.parent

# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}

jsGA.Organism = Backbone.Model.extend(
    defaults:
        type: 'base'

    initialize: (options) ->
        if not @has('chromosome')
            chromosomeLength = options.chromosomeLength || 10
            @set({chromosome: @generateChromosome(chromosomeLength)})

        @bind('change:chromosome', @updateFitness, this)
        @bind('change:fitness', @updateFitnessDef, this)

    fitnessDef: ->
        0

    updateFitnessDef: ->
        @fitnessDef = new Function(@get('fitness'))
        @updateFitness()

    updateFitness: ->
        @_fitness = @fitnessDef.apply(this)

    fitness: ->
        if not @_fitness
            @updateFitnessDef()

        @_fitness

    generateChromosome: (chromosomeLength) ->
        @_randomBase() for i in [0...chromosomeLength]

    _randomBase: ->
        choice = Math.floor(Math.random() * @get('bases').length)
        @get('bases')[choice]

    clone: ->
        clone = Backbone.Model.prototype.clone.apply(this)
        clone.unset('id', {silent: true})
        clone

    #
    # Mutate this organism's chromosome at random.
    # 
    # The chance that a given base in this organism's chromosome
    # is represented by the `mutationProbability` attribute.
    #
    # Assuming that a mutation does occur, this method will choose a new
    # base randomly from the `bases` attribute with a unform probability
    # of choosing each base. The chosen base will replace the existing
    # base of the chromosome.
    #
    # This method returns nothing.
    #
    #
    mutate: ->
        chromosome = @get('chromosome')
        mutationOccurred = false

        for locus in [0...chromosome.length]
            if Math.random() < @get('mutationProbability')
                chromosome[locus] = @_randomBase()
                mutationOccurred = true

        if mutationOccurred 
            @set({chromosome: chromosome}, {silent: true})

    #
    # Crossover this organism with another.
    #
    # The probability of a crossover occuring is given by the crossoverProbability
    # attribute. If a crossover does not occur, a clone of each parent will
    # be returned instead. A crossover is performed by select a random locus
    # by choosing a random number between [1, chromosomeLength-1]
    # 
    # Math.random() gives us a range of [0, 1), which when multiplied by
    # the length of our chromosome gives a range of:
    #
    #   [0, chromosomeLength) == [0, chromosomeLength-1]
    #
    # Mulitpling instead by the chromosome length less one results in:
    #
    #   [0, chromosomeLength-2]
    #
    # Adding one to this results in:
    #
    #   [1, chromosomeLength-1]
    #
    # which is the desired range.
    #
    # This method returns two new Organism instances.
    #
    # If a crossover occurs, the first organism will have the initial bases
    # of this organism's chromosome and bases from the chosen locus onward
    # will be from the other organism. The second organism will have initial
    # bases from the other organism and those from the locus onward of this
    # organism.
    #
    crossover: (otherOrganism) ->
        if Math.random() < @get('crossoverProbability')
            # Get the length of the shorter of the two chromosomes to be
            # crossed-over.
            chromosomeLength = Math.min(@get('chromosome').length,
                                        otherOrganism.get('chromosome').length)
            # Pick a position (locus) for the crossover
            locus = (Math.random() * (chromosomeLength - 1.0)) + 1.0
            # Construct the two child chromosomes
            childOneChromosome = @get('chromosome')
                .slice(0, locus)
                .concat(otherOrganism.get('chromosome').slice(locus))
            childTwoChromosome = otherOrganism.get('chromosome')
                .slice(0, locus)
                .concat(@get('chromosome').slice(locus))

            attrs = @toJSON()
            return [new jsGA.Organism(_.extend(attrs, {chromosome: childOneChromosome})),
                    new jsGA.Organism(_.extend(attrs, {chromosome: childTwoChromosome}))]
        else
            return [@clone(), otherOrganism.clone()]
)

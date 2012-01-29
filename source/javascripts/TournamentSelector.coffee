# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}

class jsGA.TournamentSelector
    constructor: (@size) ->

    # Choose a single organism by holding a tournament between n random
    # participant organisms in the population, and selecting the fittest.
    chooseOne: (n, population) ->
        random = (from, to) ->
            range = to - from
            from + Math.random() * range

        # choose a random subset of size n of the population
        choices = (Math.floor(random(0, population.length)) for i in [0...n])
        tournament = (population.at(position) for position in choices)

        # Find the organism with the largest fitness
        _.max(tournament, (organism) ->
            organism.fitness()
        )

    #
    # Choose a pair of organisms.
    #
    # This may select the same organism twice.
    #
    # Returns a list of two Organism instances.
    #
    choose: (population) ->
        n = @size
        [@chooseOne(n, population), @chooseOne(n, population)]

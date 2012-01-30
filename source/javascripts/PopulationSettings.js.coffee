# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}

jsGA.PopulationSettingsCollection = Backbone.Collection.extend(
    localStorage: new Store('populationsettings')
)

jsGA.PopulationSettings = Backbone.Model.extend(
    localStorage: new Store('populationsettings')

    defaults:
        size: 20
        selectionMechanism: 'fp'
        elitism: 0.0
        crossoverProbability: 70.0
        mutationProbability: 0.1
        fitness: "return _.reduce(this.get('chromosome'), function(memo, num){ return memo + num; }, 0);"
        bases: [0, 1]
        chromosomeLength: 10

    selectionMechanismNames:
        fp: 'Fitness Proportionate'
        tournament: 'Tournament'

    initialize: (options) ->
        options = options || {}

    escape: (attribute) ->
        if attribute == 'selectionMechanism'
            return this.selectionMechanismNames[this.get(attribute)]
        else
            return Backbone.Model.prototype.escape.call(this, attribute)

    isDefault: (attribute) ->
        this.defaults[attribute] == this.get(attribute)

    validate: (attrs) ->
        if 'size' of attrs and attrs.size < 2
            return 'Population size should be at least 2'

        if 'elitism' of attrs and (attrs.elitism < 0 or attrs.elitism > 100)
            return 'Elitism must be a percentage (a value between 0 and 100)'

        if 'crossoverProbability' of attrs
            if attrs.crossoverProbability < 0 || attrs.crossoverProbability > 100
                return 'Crossover probability must be a value between 0.0 and 100.0'

        if 'mutationProbability' of attrs
            if attrs.mutationProbability < 0 || attrs.mutationProbability > 100
                return 'Mutation probability must be a value between 0.0 and 100.0'

        if 'selectionMechanism' of attrs
            validMechanisms = {fp: true, tournament: true}
            if !(attrs.selectionMechanism of validMechanisms)
                return 'Selection mechanism is not supported'

        if 'tournamentSize' of attrs
            if attrs.tournamentSize > @get('size')
                return 'Tournament size must be smaller than the population size'

        if 'bases' of attrs
            if not attrs.bases
                return 'A set of chromosomal bases must be selected'

            if attrs.bases.length == 0
                return 'There must be at least one chromosome base'

        if 'fitness' of attrs
            if typeof attrs.fitness != 'string'
                return 'Fitness function must be a string'

        if 'chromosomeLength' of attrs
           if attrs.chromosomeLength <= 0
               return 'Chromosome must have at least one base'
)

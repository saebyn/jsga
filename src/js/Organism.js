// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.Organism = Backbone.Model.extend({
    defaults: {
        type: 'base'
    },

    initialize: function (options) {
        if ( !this.has('chromosome') ) {
            var chromosomeLength = options.chromosomeLength || 10;
            this.set({chromosome: this.generateChromosome(chromosomeLength)});
        }

        this.bind('change:chromosome', this.updateFitness, this);
        this.bind('change:fitness', this.updateFitness, this);
    },

    updateFitness: function () {
        var f = new Function(this.get('fitness'));
        this._fitness = f.apply(this);
    },

    fitness: function () {
        if ( !this._fitness ) {
            this.updateFitness();
        }

        return this._fitness;
    },

    generateChromosome: function (chromosomeLength) {
        var chromosome = [];

        for ( var i = 0 ; i < chromosomeLength ; i++ )
            chromosome.push(this._randomBase());

        return chromosome;
    },

    _randomBase: function () {
        var choice = Math.floor(Math.random() * this.get('bases').length);
        return this.get('bases')[choice];
    },

    clone: function () {
        var clone = Backbone.Model.prototype.clone.apply(this);
        clone.unset('id', {silent: true});
        return clone;
    },

    /*
     * Mutate this organism's chromosome at random.
     * 
     * The chance that a given base in this organism's chromosome
     * is represented by the `mutationProbability` attribute.
     *
     * Assuming that a mutation does occur, this method will choose a new
     * base randomly from the `bases` attribute with a unform probability
     * of choosing each base. The chosen base will replace the existing
     * base of the chromosome.
     *
     * This method returns nothing.
     *
     */
    mutate: function () {
        var chromosome = this.get('chromosome');
        var mutationOccurred = false;

        for ( var locus = 0 ; locus < chromosome.length ; locus++ ) {
            if ( Math.random() < this.get('mutationProbability') ) {
                chromosome[locus] = this._randomBase();
                mutationOccurred = true;
            }
        }

        if ( mutationOccurred ) {
            this.unset('chromosome');
            this.set({chromosome: chromosome});
        }
    },

    /*
     * Crossover this organism with another.
     *
     * The probability of a crossover occuring is given by the crossoverProbability
     * attribute. If a crossover does not occur, a clone of each parent will
     * be returned instead. A crossover is performed by select a random locus
     * by choosing a random number between [1, chromosomeLength-1]
     * 
     * Math.random() gives us a range of [0, 1), which when multiplied by
     * the length of our chromosome gives a range of:
     *
     *   [0, chromosomeLength) == [0, chromosomeLength-1]
     *
     * Mulitpling instead by the chromosome length less one results in:
     *
     *   [0, chromosomeLength-2]
     *
     * Adding one to this results in:
     *
     *   [1, chromosomeLength-1]
     *
     * which is the desired range.
     *
     * This method returns two new Organism instances.
     *
     * If a crossover occurs, the first organism will have the initial bases
     * of this organism's chromosome and bases from the chosen locus onward
     * will be from the other organism. The second organism will have initial
     * bases from the other organism and those from the locus onward of this
     * organism.
     *
     */
    crossover: function (otherOrganism) {
        if ( Math.random() < this.get('crossoverProbability') ) {
            // Get the length of the shorter of the two chromosomes to be
            // crossed-over.
            var chromosomeLength = Math.min(this.get('chromosome').length,
                                            otherOrganism.get('chromosome').length),
            // Pick a position (locus) for the crossover
                locus = (Math.random() * (chromosomeLength - 1.0)) + 1.0,
            // Construct the two child chromosomes
                childOneChromosome = this.get('chromosome')
                                         .slice(0, locus)
                                         .concat(otherOrganism.get('chromosome')
                                                              .slice(locus)),
                childTwoChromosome = otherOrganism.get('chromosome')
                                                  .slice(0, locus)
                                                  .concat(this.get('chromosome')
                                                              .slice(locus));

            var attrs = this.toJSON();
            return [new jsGA.Organism(_.extend(attrs, {chromosome: childOneChromosome})),
                    new jsGA.Organism(_.extend(attrs, {chromosome: childTwoChromosome}))];
        } else {
            return [this.clone(), otherOrganism.clone()];
        }
    }
});

}).call(this);

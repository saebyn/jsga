// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.FitnessProportionateSelector = function () {
};

_.extend(jsGA.FitnessProportionateSelector.prototype, {
    /**
     * Choose a pair of organisms randomly, but where each organism has
     * a likelyhood of being selected proportional to its fitness.
     *
     * This may select the same organism twice.
     *
     * Returns a list of two Organism instances.
     *
     */
    choose: function (population) {
        var choices = [];
        // Continue until we have made two choices.
        // This loop should not run more than twice.
        while ( choices.length < 2 ) {
            // Choose a random value in the range from 0 to the sum of all
            // of the fitness values of the organisms in this population.
            var random = Math.floor(Math.random() * population.totalFitness());
            var accumulatedFitness = 0.0;

            // Iterate through all organisms in the population,
            // accumulating their fitness, until a selection is made.
            for ( var j = 0 ; j < population.length ; j++ ) {
                var organism = population.at(j);
                var fitness = organism.fitness();

                // If the random value is in the proportional subrange
                // of fitness of this organism
                if ( random >= accumulatedFitness &&
                     random < accumulatedFitness + fitness ) {
                    choices.push(organism);  // choose it
                    break;  // search for the next random selection
                } else {
                    accumulatedFitness += fitness;
                }
            }
        }
        return choices;
    }
});

}).call(this);

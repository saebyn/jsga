// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.Population = Backbone.Collection.extend({
    initialize: function (models, options) {
        options = options || {};
        
        this.selector = options.selector || new jsGA.FitnessProportionateSelector;
        this.settings = new jsGA.PopulationSettings;
        this.model = options.model || jsGA.Organism;
    },

    /**
     * comparator
     *
     * Causes the collection to be sorted by fitness in descending order.
     */
    comparator: function (organism) {
        return -organism.fitness();
    },

    /**
     * seed
     *
     * Add organisms to the population.
     *
     */
    seed: function(settings) {
        // Keep the settings model around for later use.
        this.settings.set(settings.toJSON());

        // Define the default options for population seeding.
        var defaultOptions = {size: 2};
        var options = {};

        options = settings.toJSON();

        // Override the default options with any that were passed in.
        options = _.extend(defaultOptions, options);

        for ( var i = 0 ; i < options.size ; i++ ) {
            this.add(options);
        }
    },

    /**
     * run
     *
     * Select, crossover, and mutate for the specified number of
     * generations.
     *
     */
    run: function (generations) {
        if ( generations === undefined )
            generations = 1;

        if ( generations <= 0 ) {
            return;
        }

        this.step();
        this.trigger('generation', generations-1);
        var self = this;
        this.timer = setTimeout(function () {
            self.run(generations-1);
        }, 100);
    },

    stop: function () {
        if ( this.timer ) {
            clearTimeout(this.timer);
            this.timer = false;
        }
    },

    step: function () {
        var newOrganisms = this.topProportion(this.settings.get('elitism') / 100.0);
        var newOrganismsNeeded = this.length - newOrganisms.length;

        while ( newOrganismsNeeded > 0 ) {
            var choices = this.selector.choose(this);
            if ( choices === false )
                break;

            // Perform the crossover operation.
            var children = choices[0].crossover(choices[1]);
            children[0].mutate();
            children[1].mutate();
            // Append the children to the array of new organisms.
            newOrganisms.push.apply(newOrganisms, children);
            // Now we need two less organisms that we did before.
            newOrganismsNeeded -= 2;
        }

        this.reset(newOrganisms);
    },

    totalFitness: function () {
        return this.reduce(function(memo, organism){ return memo + organism.fitness(); }, 0.0);
    },

    topProportion: function (proportion) {
        var total = Math.floor(this.length * proportion);
        return this.first(total);
    }
});

}).call(this);

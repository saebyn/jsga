// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.PopulationSettings = Backbone.Model.extend({
    defaults: {
        size: 20,
        selectionMechanism: 'fp',
        elitism: 0.0,
        crossoverProbability: 70.0,
        mutationProbability: 0.1,
        fitness: "return _.reduce(this.get('chromosome'), function(memo, num){ return memo + num; }, 0);",
        bases: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        chromosomeLength: 10,
    },

    selectionMechanismNames: {
        fp: 'Fitness Proportionate',
        tournament: 'Tournament'
    },

    initialize: function (options) {
        options = options || {};
    },

    escape: function (attribute) {
        if ( attribute === 'selectionMechanism' ) {
            return this.selectionMechanismNames[this.get(attribute)];
        } else {
            return Backbone.Model.prototype.escape.call(this, attribute);
        }
    },

    isDefault: function (attribute) {
        return this.defaults[attribute] === this.get(attribute);
    },

    validate: function (attrs) {
        if ( 'size' in attrs ) {
            if ( attrs.size < 2 ) {
                return 'Population size should be at least 2';
            }
        }

        if ( 'elitism' in attrs ) {
            if ( attrs.elitism < 0 || attrs.elitism > 100 ) {
                return 'Elitism must be a percentage (a value between 0 and 100)';
            }
        }

        if ( 'crossoverProbability' in attrs ) {
            if ( attrs.crossoverProbability < 0 || attrs.crossoverProbability > 100 ) {
                return 'Crossover probability must be a value between 0.0 and 100.0';
            }
        }

        if ( 'mutationProbability' in attrs ) {
            if ( attrs.mutationProbability < 0 || attrs.mutationProbability > 100 ) {
                return 'Mutation probability must be a value between 0.0 and 100.0';
            }
        }

        if ( 'selectionMechanism' in attrs ) {
            var validMechanisms = {fp: true, tournament: true};
            if ( !(attrs.selectionMechanism in validMechanisms) ) {
                return 'The selectedd selection mechanism is not supported';
            }
        }

        if ( 'bases' in attrs ) {
            if ( attrs.bases.length == 0 ) {
                return 'There must be at least one chromosome base';
            }
        }

        if ( 'fitness' in attrs ) {
            if ( typeof attrs.fitness !== 'string' ) {
                return 'The fitness function must be a string';
            }
        }

        if ( 'chromosomeLength' in attrs ) {
           if ( attrs.chromosomeLength <= 0 ) {
               return 'The chromosome must have at least one base';
           }
        }
    }
});

}).call(this);
